import { DynamicBorder, ExtensionEditorComponent, keyHint, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Container, Spacer, Text } from "@earendil-works/pi-tui";
import { Type, type Static } from "typebox";

export const CUSTOM_OPTION_LABEL = "Something else.";
const RECOMMENDED_SUFFIX = /\s*\(recommended\)\s*$/i;

export type AskQuestionDetails = {
	question: string;
	options: string[];
	answer: string | null;
	wasCustom?: boolean;
	selectedIndex?: number;
	comment?: string;
	error?: string;
};

const optionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option", minLength: 1 }),
	description: Type.Optional(
		Type.String({ description: "Optional explanation of the option", minLength: 1 }),
	),
});

export const parameters = Type.Object({
	question: Type.String({ description: "Question to ask the user", minLength: 1 }),
	options: Type.Array(optionSchema, {
		description: "Meaningful options, ordered with the recommended option first",
		minItems: 1,
	}),
});

export type AskQuestionParams = Static<typeof parameters>;

export function questionError(question: string, options: { label: string }[]): string | undefined {
	if (!question) return "Question must not be blank";
	const labels = options.map((option) => option.label);
	if (labels.some((label) => !label)) return "Option labels must not be blank";
	if (new Set(labels.map((label) => label.toLowerCase())).size !== labels.length) return "Option labels must be unique";
	if (labels.some((label) => label.toLowerCase() === CUSTOM_OPTION_LABEL.toLowerCase())) {
		return `Option label "${CUSTOM_OPTION_LABEL}" is reserved`;
	}
}

export function questionChoices(options: { label: string; description?: string }[]) {
	const choices = options.map((option, index) => {
		const label = index === 0
			? `${option.label.replace(RECOMMENDED_SUFFIX, "")} (Recommended)`
			: option.label;
		return { label: `${index + 1}. ${label}`, description: option.description };
	});
	choices.push({ label: `${options.length + 1}. ${CUSTOM_OPTION_LABEL}`, description: undefined });
	return choices;
}

export function result(details: AskQuestionDetails) {
	let text: string;
	if (details.error) text = `Error: ${details.error}`;
	else if (!details.answer) text = "User cancelled question";
	else if (details.wasCustom) text = `User wrote: ${details.answer}`;
	else {
		text = `User selected: ${details.selectedIndex}. ${details.answer}`;
		if (details.comment) text += `\nUser comment: ${details.comment}`;
	}

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
			"In interactive TUI sessions, ask the user one question with meaningful options or a custom answer. The first option is shown as recommended. The user can select an option and add details with Tab.",
		promptSnippet:
			"In interactive TUI sessions, ask the user one question with meaningful options or a custom answer",
		promptGuidelines: [
			"In interactive TUI sessions, use ask_question instead of plain assistant text whenever user input is needed to proceed; in non-interactive sessions, ask in plain assistant text.",
			"Use ask_question for exactly one focused question at a time. Offer as many concise, meaningful options as needed. Put the recommended option first and omit '(Recommended)' from its label.",
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
			const error = questionError(question, options);
			if (error) return result({ question, options: labels, answer: null, error });

			const choices = questionChoices(options);

			let initialIndex = 0;
			while (true) {
				const selected = await ctx.ui.custom<{ index: number; withComment: boolean } | null>(
					(tui, theme, keybindings, done) => {
						let selectedIndex = initialIndex;
						const maxVisible = Math.min(choices.length, 5);
						const list = {
							render(width: number): string[] {
								const start = Math.max(0, Math.min(selectedIndex - Math.floor(maxVisible / 2), choices.length - maxVisible));
								const end = Math.min(start + maxVisible, choices.length);
								const lines: string[] = [];
								for (let index = start; index < end; index++) {
									const choice = choices[index]!;
									const selected = index === selectedIndex;
									const label = `${selected ? "→" : " "} ${choice.label}`;
									lines.push(...new Text(theme.fg(selected ? "accent" : "text", theme.bold(label)), 1, 0).render(width));
									if (choice.description) lines.push(...new Text(theme.fg("muted", choice.description), 5, 0).render(width));
									if (index < end - 1) lines.push("");
								}
								if (start > 0 || end < choices.length) {
									lines.push(...new Text(theme.fg("dim", `(${selectedIndex + 1}/${choices.length})`), 1, 0).render(width));
								}
								return lines;
							},
							invalidate() {},
						};
						const onAbort = () => done(null);
						if (signal?.aborted) onAbort();
						else signal?.addEventListener("abort", onAbort, { once: true });

						const container = new Container();
						container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));
						container.addChild(new Spacer(1));
						container.addChild(new Text(theme.fg("text", theme.bold(question)), 1, 0));
						container.addChild(new Spacer(1));
						container.addChild(list);
						container.addChild(new Spacer(1));
						container.addChild(new Text(theme.fg("dim", `↑↓ navigate • ${keyHint("tui.select.confirm", "select")} • ${keyHint("tui.input.tab", "add details")} • ${keyHint("tui.select.cancel", "cancel")}`), 1, 0));
						container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));

						return {
							render: (width: number) => container.render(width),
							invalidate: () => container.invalidate(),
							dispose: () => signal?.removeEventListener("abort", onAbort),
							handleInput(data: string) {
								if (keybindings.matches(data, "tui.select.up")) selectedIndex = (selectedIndex - 1 + choices.length) % choices.length;
								else if (keybindings.matches(data, "tui.select.down")) selectedIndex = (selectedIndex + 1) % choices.length;
								else if (keybindings.matches(data, "tui.select.confirm") || keybindings.matches(data, "tui.input.tab")) {
									done({ index: selectedIndex, withComment: keybindings.matches(data, "tui.input.tab") && selectedIndex !== options.length });
									return;
								} else if (keybindings.matches(data, "tui.select.cancel")) {
									done(null);
									return;
								}
								tui.requestRender();
							},
						};
					},
				);
				if (!selected) return result({ question, options: labels, answer: null });

				if (selected.index === options.length) {
					const answer = (await ctx.ui.input(CUSTOM_OPTION_LABEL, "Type your answer", { signal }))?.trim();
					return result({
						question,
						options: labels,
						answer: answer || null,
						wasCustom: true,
					});
				}

				let comment: string | undefined;
				if (selected.withComment) {
					const entered = await ctx.ui.custom<string | undefined>((tui, _theme, keybindings, done) => {
						const editor = new ExtensionEditorComponent(
							tui,
							keybindings,
							`Add details for ${options[selected.index]!.label}`,
							undefined,
							done,
							() => done(undefined),
						);
						const onAbort = () => done(undefined);
						if (signal?.aborted) onAbort();
						else signal?.addEventListener("abort", onAbort, { once: true });
						return Object.assign(editor, {
							dispose: () => signal?.removeEventListener("abort", onAbort),
						});
					});
					if (signal?.aborted) return result({ question, options: labels, answer: null });
					if (entered === undefined) {
						initialIndex = selected.index;
						continue;
					}
					comment = entered.trim() || undefined;
				}

				return result({
					question,
					options: labels,
					answer: options[selected.index]!.label,
					wasCustom: false,
					selectedIndex: selected.index + 1,
					comment,
				});
			}
		},
	});
}
