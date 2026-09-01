import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const CUSTOM_OPTION_LABEL = "Something else.";
const RECOMMENDED_SUFFIX = /\s*\(recommended\)\s*$/i;

type AskQuestionDetails = {
	question: string;
	options: string[];
	answer: string | null;
	wasCustom?: boolean;
	selectedIndex?: number;
	error?: string;
};

const optionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option", minLength: 1 }),
	description: Type.Optional(
		Type.String({ description: "Optional explanation of the option", minLength: 1 }),
	),
});

const parameters = Type.Object({
	question: Type.String({ description: "Question to ask the user", minLength: 1 }),
	options: Type.Array(optionSchema, {
		description: "One to three meaningful options, ordered with the recommended option first",
		minItems: 1,
		maxItems: 3,
	}),
});

function result(details: AskQuestionDetails) {
	let text: string;
	if (details.error) text = `Error: ${details.error}`;
	else if (!details.answer) text = "User cancelled question";
	else if (details.wasCustom) text = `User wrote: ${details.answer}`;
	else text = `User selected: ${details.selectedIndex}. ${details.answer}`;

	return {
		content: [{ type: "text" as const, text }],
		details,
	};
}

export default function askQuestionExtension(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "ask_question",
		label: "Ask Question",
		description:
			"In interactive TUI sessions, ask the user one question with one to three options or a custom answer. The first option is shown as recommended.",
		promptSnippet:
			"In interactive TUI sessions, ask the user one question with up to three options or a custom answer",
		promptGuidelines: [
			"In interactive TUI sessions, use ask_question instead of plain assistant text whenever user input is needed to proceed; in non-interactive sessions, ask in plain assistant text.",
			"Use ask_question for exactly one focused question at a time, with one to three concise, meaningful options. Put the recommended option first and omit '(Recommended)' from its label.",
			"Give ask_question option descriptions only when they explain meaningful trade-offs; never repeat option labels.",
		],
		parameters,
		executionMode: "sequential",

		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const question = params.question.trim();
			const options = params.options.map((option) => ({
				label: option.label.trim(),
				description: option.description?.trim(),
			}));
			const labels = options.map((option) => option.label);

			if (ctx.mode !== "tui") {
				return result({
					question,
					options: labels,
					answer: null,
					error: "UI not available (running in non-interactive mode)",
				});
			}
			if (!question) {
				return result({ question, options: labels, answer: null, error: "Question must not be blank" });
			}
			if (options.some((option) => !option.label)) {
				return result({ question, options: labels, answer: null, error: "Option labels must not be blank" });
			}
			if (new Set(labels.map((label) => label.toLowerCase())).size !== labels.length) {
				return result({ question, options: labels, answer: null, error: "Option labels must be unique" });
			}
			if (labels.some((label) => label.toLowerCase() === CUSTOM_OPTION_LABEL.toLowerCase())) {
				return result({
					question,
					options: labels,
					answer: null,
					error: `Option label "${CUSTOM_OPTION_LABEL}" is reserved`,
				});
			}

			const choices = options.map((option, index) => {
				const label = index === 0
					? `${option.label.replace(RECOMMENDED_SUFFIX, "")} (Recommended)`
					: option.label;
				return `${index + 1}. ${label}${option.description ? ` — ${option.description}` : ""}`;
			});
			choices.push(`${choices.length + 1}. ${CUSTOM_OPTION_LABEL}`);

			const selected = await ctx.ui.select(question, choices, { signal });
			const selectedIndex = selected === undefined ? -1 : choices.indexOf(selected);
			if (selectedIndex === -1) return result({ question, options: labels, answer: null });

			if (selectedIndex === options.length) {
				const answer = (await ctx.ui.input(CUSTOM_OPTION_LABEL, "Type your answer", { signal }))?.trim();
				return result({
					question,
					options: labels,
					answer: answer || null,
					wasCustom: true,
				});
			}

			return result({
				question,
				options: labels,
				answer: options[selectedIndex]!.label,
				wasCustom: false,
				selectedIndex: selectedIndex + 1,
			});
		},
	});
}
