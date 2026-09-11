import {
	existsSync,
	mkdirSync,
	readFileSync,
	readdirSync,
	renameSync,
	unlinkSync,
	writeFileSync,
} from "node:fs";
import { dirname, join } from "node:path";
import {
	CONFIG_DIR_NAME,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Input, Key, matchesKey, truncateToWidth } from "@earendil-works/pi-tui";

type ThinkingLevel = ReturnType<ExtensionAPI["getThinkingLevel"]>;

type Step = {
	command: string;
	provider: string;
	model: string;
	thinkingLevel: ThinkingLevel;
};

type PickerItem = {
	value: string;
	label: string;
	description?: string;
};

const CONTEXT_MARKER = "flow-step";
const ABNORMAL_STOP_REASONS = new Set(["aborted", "error", "length"]);
const FLOW_FILE_PREFIX = "flow_";
const FLOW_FILE_SUFFIX = ".yaml";
const RESERVED_FLOW_NAMES = new Set(["setup", "abort"]);
const FLOW_NAME_PATTERN = /^[a-z0-9][a-z0-9_-]*$/;
const WORKFLOW_KEYS = ["steps"];
const STEP_KEYS = ["command", "provider", "model", "thinkingLevel"];
const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;

function getCommandName(command: string): string | undefined {
	return command.match(/^\/(\S+)/)?.[1];
}

function expandTask(command: string, task: string): string {
	return command.replaceAll("$TASK", task);
}

function getConfigDir(ctx: ExtensionContext): string {
	return join(ctx.cwd, CONFIG_DIR_NAME);
}

function assertProjectTrusted(ctx: ExtensionContext): void {
	if (!ctx.isProjectTrusted())
		throw new Error(`flow configuration requires project trust: ${getConfigDir(ctx)}`);
}

function validateFlowName(name: string): void {
	if (!FLOW_NAME_PATTERN.test(name))
		throw new Error("flow name must match [a-z0-9][a-z0-9_-]*");
	if (RESERVED_FLOW_NAMES.has(name))
		throw new Error(`flow name is reserved: ${name}`);
}

function getFlowPath(ctx: ExtensionContext, name: string): string {
	validateFlowName(name);
	return join(getConfigDir(ctx), `${FLOW_FILE_PREFIX}${name}${FLOW_FILE_SUFFIX}`);
}

function listFlowNames(ctx: ExtensionContext): string[] {
	assertProjectTrusted(ctx);
	const configDir = getConfigDir(ctx);
	if (!existsSync(configDir)) return [];

	return readdirSync(configDir, { withFileTypes: true })
		.filter((entry) => entry.isFile())
		.map((entry) => entry.name.match(/^flow_([a-z0-9][a-z0-9_-]*)\.yaml$/)?.[1])
		.filter((name): name is string => name !== undefined && !RESERVED_FLOW_NAMES.has(name))
		.sort();
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function validateKeys(value: Record<string, unknown>, expected: string[], location: string): void {
	const keys = Object.keys(value);
	const unknown = keys.filter((key) => !expected.includes(key));
	const missing = expected.filter((key) => !Object.hasOwn(value, key));
	const errors = [
		...unknown.map((key) => `unknown key ${key}`),
		...missing.map((key) => `missing key ${key}`),
	];

	if (errors.length > 0)
		throw new Error(`${location}: ${errors.join(", ")}`);
}

function validateStep(value: unknown, index: number, configPath: string): Step {
	const location = `flow config ${configPath}, step ${index + 1}`;
	if (!isRecord(value))
		throw new Error(`${location} must be a mapping`);

	validateKeys(value, STEP_KEYS, location);
	const command = value.command;
	const provider = value.provider;
	const model = value.model;
	const thinkingLevel = value.thinkingLevel;

	if (typeof command !== "string" || !command.trim())
		throw new Error(`${location}: command must be a non-empty string`);
	if (typeof provider !== "string" || !provider.trim())
		throw new Error(`${location}: provider must be a non-empty string`);
	if (typeof model !== "string" || !model.trim())
		throw new Error(`${location}: model must be a non-empty string`);
	if (typeof thinkingLevel !== "string" || !THINKING_LEVELS.includes(thinkingLevel as ThinkingLevel))
		throw new Error(`${location}: thinkingLevel must be one of ${THINKING_LEVELS.join(", ")}`);

	return { command, provider, model, thinkingLevel: thinkingLevel as ThinkingLevel };
}

async function getYaml() {
	try {
		return await import("yaml");
	} catch (error) {
		throw new Error(`flow support requires yaml: ${error instanceof Error ? error.message : String(error)}`);
	}
}

async function loadFlow(ctx: ExtensionContext, name: string): Promise<Step[]> {
	assertProjectTrusted(ctx);
	const flowPath = getFlowPath(ctx, name);
	if (!existsSync(flowPath))
		throw new Error(`flow not found: ${name}`);

	let source: string;
	try {
		source = readFileSync(flowPath, "utf8");
	} catch (error) {
		throw new Error(`could not read flow ${name}: ${error instanceof Error ? error.message : String(error)}`);
	}

	const { parseDocument } = await getYaml();
	let document: ReturnType<typeof parseDocument>;
	try {
		document = parseDocument(source);
	} catch (error) {
		throw new Error(`could not parse flow ${name}: ${error instanceof Error ? error.message : String(error)}`);
	}
	if (document.errors.length > 0)
		throw new Error(`invalid flow ${name}: ${document.errors.map((error) => error.message).join("; ")}`);

	let config: unknown;
	try {
		config = document.toJS();
	} catch (error) {
		throw new Error(`could not read flow ${name}: ${error instanceof Error ? error.message : String(error)}`);
	}
	if (!isRecord(config))
		throw new Error(`flow ${name} must be a mapping with a steps key`);

	validateKeys(config, WORKFLOW_KEYS, `flow ${name}`);
	if (!Array.isArray(config.steps) || config.steps.length === 0)
		throw new Error(`flow ${name}: steps must be a non-empty list`);

	return config.steps.map((step, index) => validateStep(step, index, flowPath));
}

async function saveFlow(ctx: ExtensionContext, name: string, workflow: Step[]): Promise<void> {
	assertProjectTrusted(ctx);
	const { stringify } = await getYaml();
	const flowPath = getFlowPath(ctx, name);
	const tempPath = `${flowPath}.${process.pid}.${Date.now()}.tmp`;

	mkdirSync(dirname(flowPath), { recursive: true });
	try {
		writeFileSync(tempPath, stringify({ steps: workflow }), { encoding: "utf8", mode: 0o600 });
		renameSync(tempPath, flowPath);
	} finally {
		if (existsSync(tempPath)) {
			try {
				unlinkSync(tempPath);
			} catch {}
		}
	}
}

function renameFlow(ctx: ExtensionContext, from: string, to: string): void {
	assertProjectTrusted(ctx);
	const fromPath = getFlowPath(ctx, from);
	const toPath = getFlowPath(ctx, to);
	if (!existsSync(fromPath))
		throw new Error(`flow not found: ${from}`);
	if (existsSync(toPath))
		throw new Error(`flow already exists: ${to}`);
	renameSync(fromPath, toPath);
}

function deleteFlow(ctx: ExtensionContext, name: string): void {
	assertProjectTrusted(ctx);
	const flowPath = getFlowPath(ctx, name);
	if (!existsSync(flowPath))
		throw new Error(`flow not found: ${name}`);
	unlinkSync(flowPath);
}

function fuzzyScore(item: PickerItem, query: string): number | undefined {
	const needle = query.toLowerCase();
	if (!needle) return 0;

	const text = `${item.label} ${item.description ?? ""} ${item.value}`.toLowerCase();
	if (text.startsWith(needle)) return 1000 - text.length;
	const substring = text.indexOf(needle);
	if (substring >= 0) return 800 - substring;

	let cursor = 0;
	let score = 0;
	for (const character of needle) {
		const next = text.indexOf(character, cursor);
		if (next < 0) return undefined;
		score -= next - cursor;
		cursor = next + 1;
	}
	return score;
}

function filterPickerItems(items: PickerItem[], query: string): PickerItem[] {
	return items
		.map((item) => ({ item, score: fuzzyScore(item, query) }))
		.filter((candidate): candidate is { item: PickerItem; score: number } => candidate.score !== undefined)
		.sort((left, right) => right.score - left.score || left.item.label.localeCompare(right.item.label))
		.map((candidate) => candidate.item);
}

async function pickFuzzy(
	ctx: ExtensionContext,
	title: string,
	items: PickerItem[],
	selectedValue?: string,
): Promise<string | undefined> {
	if (items.length === 0) {
		ctx.ui.notify(`No ${title.toLowerCase()} available`, "warning");
		return undefined;
	}

	return ctx.ui.custom<string | undefined>((tui, theme, _keybindings, done) => {
		const input = new Input();
		let selectedIndex = Math.max(0, items.findIndex((item) => item.value === selectedValue));

		function getFilteredItems(): PickerItem[] {
			return filterPickerItems(items, input.getValue());
		}

		function selectCurrent(): void {
			const item = getFilteredItems()[selectedIndex];
			if (item) done(item.value);
		}

		return {
			get focused() {
				return input.focused;
			},
			set focused(value: boolean) {
				input.focused = value;
			},
			render(width: number) {
				const renderWidth = Math.max(1, width);
				const truncate = (text: string) => truncateToWidth(text, renderWidth, "");
				const filtered = getFilteredItems();
				selectedIndex = Math.min(selectedIndex, Math.max(0, filtered.length - 1));
				const lines = [
					theme.fg("accent", "─".repeat(renderWidth)),
					theme.fg("accent", theme.bold(truncate(title))),
					...input.render(Math.max(1, renderWidth - 2)).map((line) => truncate(` ${line}`)),
				];

				if (filtered.length === 0) {
					lines.push(theme.fg("warning", truncate("  No matches")));
				} else {
					const maxVisible = 8;
					const startIndex = Math.max(
						0,
						Math.min(selectedIndex - Math.floor(maxVisible / 2), filtered.length - maxVisible),
					);
					const endIndex = Math.min(startIndex + maxVisible, filtered.length);
					for (let index = startIndex; index < endIndex; index++) {
						const item = filtered[index]!;
						const prefix = index === selectedIndex ? "→ " : "  ";
						const text = item.description ? `${item.label}  ${item.description}` : item.label;
						const line = truncateToWidth(`${prefix}${text}`, renderWidth, "");
						lines.push(index === selectedIndex ? theme.fg("accent", line) : theme.fg("text", line));
					}
					if (filtered.length > maxVisible)
						lines.push(theme.fg("dim", truncate(`  ${selectedIndex + 1}/${filtered.length}`)));
				}

				lines.push(theme.fg("dim", truncate(" ↑↓ select • Enter confirm • Esc cancel")));
				lines.push(theme.fg("accent", "─".repeat(renderWidth)));
				return lines;
			},
			invalidate() {
				input.invalidate();
			},
			handleInput(data: string) {
				const filtered = getFilteredItems();
				if (matchesKey(data, Key.up)) {
					selectedIndex = selectedIndex === 0 ? Math.max(0, filtered.length - 1) : selectedIndex - 1;
				} else if (matchesKey(data, Key.down)) {
					selectedIndex = selectedIndex === filtered.length - 1 ? 0 : selectedIndex + 1;
				} else if (matchesKey(data, Key.enter)) {
					selectCurrent();
				} else if (matchesKey(data, Key.escape)) {
					done(undefined);
				} else {
					input.handleInput(data);
					selectedIndex = 0;
				}
				tui.requestRender();
			},
		};
	});
}

export default function flow(pi: ExtensionAPI) {
	let active = false;
	let generation = 0;
	let stepIndex = -1;
	let steps: Step[] = [];
	let task = "";
	let pendingMarker: { generation: number; stepIndex: number } | undefined;
	let lastStopReason: string | undefined;

	function clearState(ctx: ExtensionContext): void {
		active = false;
		stepIndex = -1;
		steps = [];
		task = "";
		pendingMarker = undefined;
		lastStopReason = undefined;
		ctx.ui.setStatus("flow", undefined);
	}

	function stop(ctx: ExtensionContext, message: string, level: "error" | "info" = "error"): void {
		generation++;
		clearState(ctx);
		ctx.ui.notify(message, level);
	}

	function validateWorkflow(ctx: ExtensionContext, workflow: Step[]): void {
		if (workflow.length === 0)
			throw new Error("workflow must contain at least one step");

		const commands = pi.getCommands();
		const errors: string[] = [];

		for (const step of workflow) {
			const commandName = getCommandName(step.command);
			if (!commandName) {
				errors.push(`invalid step command: ${step.command}`);
			} else {
				const command = commands.find((candidate) => candidate.name === commandName);
				if (!command) {
					errors.push(`command not found: /${commandName}`);
				} else if (command.source === "extension") {
					errors.push(`step command must be a prompt or skill: /${commandName}`);
				}
			}

			if (!ctx.modelRegistry.find(step.provider, step.model)) {
				errors.push(`model not found: ${step.provider}/${step.model}`);
			}
		}

		if (errors.length > 0)
			throw new Error([...new Set(errors)].join("; "));
	}

	async function configureStep(ctx: ExtensionContext, existing?: Step): Promise<Step | undefined> {
		const commands = pi.getCommands()
			.filter((command) => command.source !== "extension")
			.map((command) => ({
				value: command.name,
				label: `/${command.name}`,
				description: command.description,
			}));
		const commandName = await pickFuzzy(ctx, "Pick command", commands, getCommandName(existing?.command ?? ""));
		if (!commandName) return undefined;

		const command = await ctx.ui.editor("Step command", existing?.command ?? `/${commandName}`);
		if (command === undefined) return undefined;

		const models = ctx.scopedModels.length > 0
			? ctx.scopedModels.map((entry) => entry.model)
			: ctx.modelRegistry.getAvailable();
		const modelItems = models.map((model, index) => ({
			value: String(index),
			label: `${model.provider}/${model.id}`,
			description: model.name,
		}));
		const selectedModel = await pickFuzzy(
			ctx,
			"Pick model",
			modelItems,
			String(models.findIndex((model) => model.provider === existing?.provider && model.id === existing?.model)),
		);
		if (selectedModel === undefined) return undefined;
		const model = models[Number(selectedModel)];
		if (!model) return undefined;

		const selectedThinkingLevel = await pickFuzzy(
			ctx,
			"Pick thinking level",
			THINKING_LEVELS.map((thinkingLevel) => ({ value: thinkingLevel, label: thinkingLevel })),
			existing?.thinkingLevel,
		);
		if (!selectedThinkingLevel) return undefined;

		return {
			command,
			provider: model.provider,
			model: model.id,
			thinkingLevel: selectedThinkingLevel as ThinkingLevel,
		};
	}

	async function editFlow(ctx: ExtensionContext, name: string, initial: Step[]): Promise<void> {
		let workflow = initial.map((step) => ({ ...step }));
		while (true) {
			const actions: PickerItem[] = [
				{ value: "add", label: "Add step", description: "Choose command, model, and thinking level" },
				...workflow.flatMap((step, index) => [
					{ value: `edit:${index}`, label: `Edit step ${index + 1}`, description: step.command },
					{ value: `remove:${index}`, label: `Remove step ${index + 1}`, description: step.command },
					...(index > 0 ? [{ value: `up:${index}`, label: `Move step ${index + 1} up`, description: step.command }] : []),
					...(index < workflow.length - 1 ? [{ value: `down:${index}`, label: `Move step ${index + 1} down`, description: step.command }] : []),
				]),
				{ value: "save", label: "Save flow", description: `${workflow.length} step${workflow.length === 1 ? "" : "s"}` },
				{ value: "cancel", label: "Back", description: "Discard unsaved step changes" },
			];
			const action = await pickFuzzy(ctx, `Edit flow: ${name}`, actions);
			if (!action || action === "cancel") return;

			if (action === "add") {
				const step = await configureStep(ctx);
				if (step) workflow.push(step);
				continue;
			}

			if (action === "save") {
				try {
					validateWorkflow(ctx, workflow);
					await saveFlow(ctx, name, workflow);
					ctx.ui.notify(`saved flow: ${name}`, "info");
					return;
				} catch (error) {
					ctx.ui.notify(`could not save flow: ${error instanceof Error ? error.message : String(error)}`, "error");
					continue;
				}
			}

			const [operation, rawIndex] = action.split(":", 2);
			const index = Number(rawIndex);
			if (!Number.isInteger(index) || !workflow[index]) continue;

			if (operation === "edit") {
				const step = await configureStep(ctx, workflow[index]);
				if (step) workflow[index] = step;
			} else if (operation === "remove") {
				const confirmed = await ctx.ui.confirm("Remove flow step?", workflow[index].command);
				if (confirmed) workflow.splice(index, 1);
			} else if (operation === "up" && index > 0) {
				[workflow[index - 1], workflow[index]] = [workflow[index]!, workflow[index - 1]!];
			} else if (operation === "down" && index < workflow.length - 1) {
				[workflow[index], workflow[index + 1]] = [workflow[index + 1]!, workflow[index]!];
			}
		}
	}

	async function setupFlows(ctx: ExtensionContext): Promise<void> {
		if (ctx.mode !== "tui") {
			ctx.ui.notify("flow setup requires an interactive TUI", "error");
			return;
		}

		while (true) {
			const flowNames = listFlowNames(ctx);
			for (const name of flowNames)
				await loadFlow(ctx, name);

			const actions: PickerItem[] = [
				{ value: "create", label: "Create flow", description: "Create a named flow" },
				...flowNames.flatMap((name) => [
					{ value: `edit:${name}`, label: `Edit flow: ${name}`, description: getFlowPath(ctx, name) },
					{ value: `rename:${name}`, label: `Rename flow: ${name}` },
					{ value: `delete:${name}`, label: `Delete flow: ${name}` },
				]),
				{ value: "cancel", label: "Cancel", description: "Close flow setup" },
			];
			const action = await pickFuzzy(ctx, "Flow setup", actions);
			if (!action || action === "cancel") return;

			if (action === "create") {
				const name = (await ctx.ui.input("Create flow", "lowercase flow name"))?.trim();
				if (!name) continue;
				try {
					validateFlowName(name);
					if (flowNames.includes(name))
						throw new Error(`flow already exists: ${name}`);
					await editFlow(ctx, name, []);
				} catch (error) {
					ctx.ui.notify(`could not create flow: ${error instanceof Error ? error.message : String(error)}`, "error");
				}
				continue;
			}

			const [operation, name] = action.split(":", 2);
			if (!name || !flowNames.includes(name)) continue;

			if (operation === "edit") {
				await editFlow(ctx, name, await loadFlow(ctx, name));
			} else if (operation === "rename") {
				const nextName = (await ctx.ui.editor("Rename flow", name))?.trim();
				if (!nextName || nextName === name) continue;
				try {
					validateFlowName(nextName);
					const confirmed = await ctx.ui.confirm("Rename flow?", `${name} → ${nextName}`);
					if (confirmed) renameFlow(ctx, name, nextName);
				} catch (error) {
					ctx.ui.notify(`could not rename flow: ${error instanceof Error ? error.message : String(error)}`, "error");
				}
			} else if (operation === "delete") {
				const confirmed = await ctx.ui.confirm("Delete flow?", name);
				if (confirmed) {
					try {
						deleteFlow(ctx, name);
					} catch (error) {
						ctx.ui.notify(`could not delete flow: ${error instanceof Error ? error.message : String(error)}`, "error");
					}
				}
			}
		}
	}

	async function launchStep(ctx: ExtensionContext, nextIndex: number, runGeneration: number): Promise<void> {
		if (!active || generation !== runGeneration)
			return;

		const step = steps[nextIndex];
		if (!step)
			throw new Error(`step not found: ${nextIndex + 1}`);

		stepIndex = nextIndex;
		lastStopReason = undefined;
		ctx.ui.setStatus("flow", `flow: ${nextIndex + 1}/${steps.length} ${step.command.split(" ")[0]}`);

		const model = ctx.modelRegistry.find(step.provider, step.model);
		if (!model)
			throw new Error(`model not found: ${step.provider}/${step.model}`);
		if (!(await pi.setModel(model)))
			throw new Error(`could not select model: ${step.provider}/${step.model}`);

		if (!active || generation !== runGeneration)
			return;

		pi.setThinkingLevel(step.thinkingLevel);
		pendingMarker = { generation: runGeneration, stepIndex: nextIndex };
		pi.sendUserMessage(expandTask(step.command, task), {
			expandPromptTemplates: true,
		});
	}

	pi.registerCommand("flow", {
		description: "Run a named flow with isolated command/provider/model/thinking-level steps",
		handler: async (args, ctx) => {
			const arg = args.trim();

			if (arg === "abort") {
				if (!active) {
					ctx.ui.notify("flow is not active", "info");
					return;
				}

				ctx.abort();
				stop(ctx, "flow aborted", "info");
				return;
			}

			if (arg === "setup") {
				if (active) {
					ctx.ui.notify("flow is already active", "error");
					return;
				}
				if (!ctx.isIdle()) {
					ctx.ui.notify("agent is busy", "error");
					return;
				}

				try {
					await setupFlows(ctx);
				} catch (error) {
					ctx.ui.notify(`flow setup stopped: ${error instanceof Error ? error.message : String(error)}`, "error");
				}
				return;
			}

			const separator = arg.search(/\s/);
			if (separator < 0) {
				ctx.ui.notify("usage: /flow <name> <task> | /flow abort | /flow setup", "info");
				return;
			}
			const name = arg.slice(0, separator);
			const flowTask = arg.slice(separator).trim();
			if (!flowTask) {
				ctx.ui.notify("usage: /flow <name> <task> | /flow abort | /flow setup", "info");
				return;
			}

			if (active) {
				ctx.ui.notify("flow is already active", "error");
				return;
			}
			if (!ctx.isIdle()) {
				ctx.ui.notify("agent is busy", "error");
				return;
			}

			try {
				const workflow = await loadFlow(ctx, name);
				validateWorkflow(ctx, workflow);
				steps = workflow;
				task = flowTask;
				active = true;
				const runGeneration = ++generation;
				await launchStep(ctx, 0, runGeneration);
			} catch (error) {
				stop(ctx, `flow stopped: ${error instanceof Error ? error.message : String(error)}`);
			}
		},
	});

	pi.on("before_agent_start", (event) => {
		const marker = pendingMarker;
		if (!active || !marker || marker.generation !== generation)
			return;

		pendingMarker = undefined;
		return {
			message: {
				customType: CONTEXT_MARKER,
				content: event.prompt,
				display: false,
				details: {
					generation: marker.generation,
					step: marker.stepIndex + 1,
				},
			},
		};
	});

	pi.on("context", (event) => {
		for (let index = event.messages.length - 1; index >= 0; index--) {
			const message = event.messages[index];
			if (message?.role === "custom" && message.customType === CONTEXT_MARKER)
				return { messages: event.messages.slice(index) };
		}
	});

	pi.on("message_end", (event) => {
		if (active && event.message.role === "assistant")
			lastStopReason = event.message.stopReason;
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (!active)
			return;

		const runGeneration = generation;
		if (!lastStopReason || ABNORMAL_STOP_REASONS.has(lastStopReason)) {
			const reason = lastStopReason ?? "no assistant response";
			stop(ctx, `flow stopped after step ${stepIndex + 1}: ${reason}`);
			return;
		}

		const nextIndex = stepIndex + 1;
		if (nextIndex >= steps.length) {
			clearState(ctx);
			ctx.ui.notify("flow complete", "info");
			return;
		}

		try {
			await launchStep(ctx, nextIndex, runGeneration);
		} catch (error) {
			stop(ctx, `flow stopped: ${error instanceof Error ? error.message : String(error)}`);
		}
	});
}
