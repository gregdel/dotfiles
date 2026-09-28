import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import {
	CONFIG_DIR_NAME,
	createAgentSession,
	DefaultResourceLoader,
	defineTool,
	DynamicBorder,
	getAgentDir,
	ModelRuntime,
	parseFrontmatter,
	ProjectTrustStore,
	SessionManager,
	SettingsManager,
	truncateHead,
	type AgentSession,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ThinkingLevel } from "@earendil-works/pi-agent-core";
import { getSupportedThinkingLevels } from "@earendil-works/pi-ai";
import { fuzzyFilter, Input, Key, matchesKey, Text, truncateToWidth, type Focusable } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import {
	CUSTOM_OPTION_LABEL,
	parameters as questionParameters,
	questionChoices,
	questionError,
	result as questionResult,
	type AskQuestionDetails,
	type AskQuestionParams,
} from "./ask-question";

const NAMES = ["Joe", "Bob", "Sam", "Max", "Leo", "Ben", "Tom", "Dan", "Ray", "Jay"] as const;
type AgentName = (typeof NAMES)[number];
type Status = "running" | "waiting" | "done" | "failed" | "aborted";

interface PendingQuestion {
	params: AskQuestionParams;
	resolve: (answer: ReturnType<typeof questionResult>) => void;
	signal?: AbortSignal;
	onAbort: () => void;
}

interface Child {
	name: AgentName;
	profile?: string;
	task: string;
	model: string;
	thinking: ThinkingLevel;
	session: AgentSession;
	status: Status;
	pending?: PendingQuestion;
	preflight?: Promise<void>;
	runPromise?: Promise<void>;
	createdAt: number;
	runNumber: number;
	publishedRun: number;
	abortRequested: boolean;
	destroyed: boolean;
	unsubscribe: () => void;
}

type ParentResult = { name: AgentName; profile?: string; model: string; thinking: ThinkingLevel; run: number; text: string };

type AgentProfile = { name: string; template?: string; instructions: string; source: "user" | "project" };
const PROFILE_NAME = /^[a-z][a-z0-9-]*$/;

function errorText(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}

function priority(status: Status): number {
	return { waiting: 0, running: 1, done: 2, failed: 3, aborted: 3 }[status];
}

function icon(status: Status): string {
	return { waiting: "?", running: "●", done: "✓", failed: "✗", aborted: "×" }[status];
}

function loadProfile(name: string, ctx: ExtensionContext): AgentProfile {
	if (!PROFILE_NAME.test(name)) throw new Error("Agent profile name must match [a-z][a-z0-9-]*");
	const projectPath = join(ctx.cwd, CONFIG_DIR_NAME, "agents", `${name}.md`);
	// Pi does not require a trust prompt for .pi/agents alone; require a saved decision.
	const projectExists = existsSync(projectPath);
	const project = projectExists && ctx.isProjectTrusted() && new ProjectTrustStore(getAgentDir()).get(ctx.cwd) === true;
	const path = project ? projectPath : join(getAgentDir(), "agents", `${name}.md`);
	let source: string;
	try { source = readFileSync(path, "utf8"); }
	catch (error) {
		if (projectExists && !project && !existsSync(path)) {
			throw new Error(`Project agent profile ${projectPath} requires saved project trust. Use /trust and restart Pi.`);
		}
		throw new Error(`Could not read agent profile ${path}: ${errorText(error)}`);
	}
	let frontmatter: Record<string, unknown>;
	let body: string;
	try { ({ frontmatter, body } = parseFrontmatter<Record<string, unknown>>(source)); }
	catch (error) { throw new Error(`Invalid agent profile ${path}: ${errorText(error)}`); }
	const template = frontmatter?.template;
	if (!frontmatter || typeof frontmatter !== "object" || Array.isArray(frontmatter) || frontmatter.name !== name ||
		typeof frontmatter.description !== "string" || !frontmatter.description.trim() ||
		(template !== undefined && (typeof template !== "string" || !PROFILE_NAME.test(template)))) {
		throw new Error(`Invalid agent profile ${path}: expected name: ${name}, description, and optional template`);
	}
	return { name, template: typeof template === "string" ? template : undefined, instructions: body, source: project ? "project" : "user" };
}

async function pick<T>(ctx: ExtensionContext, title: string, items: T[], label: (item: T) => string, signal?: AbortSignal): Promise<T | undefined> {
	if (signal?.aborted) return undefined;
	return ctx.ui.custom<T | undefined>((tui, theme, keys, done) => {
		const search = new Input({ prompt: " > ", placeholder: `Search ${title.toLowerCase()}` });
		let selected = 0;
		const matches = () => fuzzyFilter(items, search.getValue(), label);
		const onAbort = () => done(undefined);
		signal?.addEventListener("abort", onAbort, { once: true });
		return {
			get focused() { return search.focused; },
			set focused(value: boolean) { search.focused = value; },
			render(width: number): string[] {
				const list = matches();
				selected = Math.max(0, Math.min(selected, list.length - 1));
				const start = Math.max(0, Math.min(selected - 3, list.length - 8));
				const lines = [
					...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width),
					...new Text(theme.fg("accent", theme.bold(`Select ${title}`)), 1, 0).render(width),
					...search.render(width),
				];
				for (const [index, item] of list.slice(start, start + 8).entries()) {
					lines.push(...new Text(theme.fg(index + start === selected ? "accent" : "text", `${index + start === selected ? ">" : " "} ${label(item)}`), 1, 0).render(width).slice(0, 1));
				}
				if (!list.length) lines.push(...new Text(theme.fg("muted", "No matches"), 1, 0).render(width));
				lines.push(...new Text(theme.fg("dim", "Type to filter · ↑↓ select · Enter confirm · Esc cancel"), 1, 0).render(width));
				lines.push(...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width));
				return lines.map((line) => truncateToWidth(line, width, ""));
			},
			handleInput(data: string): void {
				const list = matches();
				if (keys.matches(data, "tui.select.cancel")) done(undefined);
				else if (keys.matches(data, "tui.select.up")) selected = Math.max(0, selected - 1);
				else if (keys.matches(data, "tui.select.down")) selected = Math.min(list.length - 1, selected + 1);
				else if (keys.matches(data, "tui.select.confirm")) {
					if (list[selected]) done(list[selected]);
				} else { search.handleInput(data); selected = 0; }
				tui.requestRender();
			},
			invalidate() { search.invalidate(); },
			dispose() { signal?.removeEventListener("abort", onAbort); },
		} satisfies Focusable;
	}, { overlay: true });
}

export default function subagents(pi: ExtensionAPI): void {
	const agents = new Map<AgentName, Child>();
	const reserved = new Set<AgentName>();
	const pendingResults: ParentResult[] = [];
	const listeners = new Set<() => void>();
	let parent: ExtensionContext | undefined;
	let alive = true;

	function changed(): void {
		if (!alive) return;
		if (parent?.mode === "tui") {
			const running = [...agents.values()].filter((agent) => agent.status === "running").length;
			const waiting = [...agents.values()].filter((agent) => agent.status === "waiting").map((agent) => agent.name);
			parent.ui.setStatus("subagents", agents.size ? `agents: ${running} running${waiting.length ? ` · ${waiting.join(", ")}?` : ""}` : undefined);
		}
		for (const listener of listeners) listener();
	}

	function flush(): void {
		if (!alive || !parent) return;
		for (const item of pendingResults.splice(0)) {
			pi.sendMessage({
				customType: "subagent-result",
				content: `[${item.name}${item.profile ? ` · ${item.profile}` : ""} · ${item.model} · ${item.thinking} · run ${item.run}]\n\n${item.text}`,
				display: true,
				details: { name: item.name, ...(item.profile ? { profile: item.profile } : {}), model: item.model, thinking: item.thinking, run: item.run },
			}, { triggerTurn: true });
		}
	}

	function publish(agent: Child, text: string): void {
		if (!alive || agent.destroyed || agent.publishedRun >= agent.runNumber) return;
		agent.publishedRun = agent.runNumber;
		const shortened = truncateHead(text, { maxBytes: 50_000, maxLines: 2000 });
		pendingResults.push({
			name: agent.name, profile: agent.profile, model: agent.model, thinking: agent.thinking, run: agent.runNumber,
			text: shortened.content + (shortened.truncated ? "\n[Result truncated; full conversation available in /agent]" : ""),
		});
		flush();
	}

	function settleQuestion(agent: Child, details: AskQuestionDetails): void {
		const pending = agent.pending;
		if (!pending) return;
		agent.pending = undefined;
		pending.signal?.removeEventListener("abort", pending.onAbort);
		if (agent.status === "waiting") agent.status = "running";
		pending.resolve(questionResult(details));
		changed();
	}

	function answerQuestion(agent: Child, answer: Omit<AskQuestionDetails, "question" | "options">): void {
		const params = agent.pending?.params;
		if (!params) return;
		settleQuestion(agent, {
			question: params.question,
			options: params.options.map((option) => option.label),
			...answer,
		});
	}

	function finishRun(agent: Child): void {
		if (agent.destroyed || agent.publishedRun >= agent.runNumber) return;
		const messages = agent.session.messages;
		const lastUser = messages.findLastIndex((message) => message.role === "user");
		const reply = messages.slice(lastUser + 1).findLast((message) => message.role === "assistant");
		if (agent.abortRequested || reply?.stopReason === "aborted") {
			agent.status = "aborted";
			publish(agent, "Child run aborted.");
		} else if (!reply || reply.stopReason === "error" || reply.stopReason === "length") {
			agent.status = "failed";
			publish(agent, `Child run failed: ${reply?.errorMessage ?? reply?.stopReason ?? "no assistant response"}`);
		} else {
			const text = reply.content.filter((part) => part.type === "text").map((part) => part.text).join("\n").trim();
			agent.status = "done";
			publish(agent, text || "Child run ended without a final text answer. See /agent for details.");
		}
		changed();
	}

	function startRun(agent: Child, text: string): void {
		const runNumber = ++agent.runNumber;
		agent.status = "running";
		agent.abortRequested = false;
		changed();
		let preflightDone!: () => void;
		agent.preflight = new Promise<void>((resolve) => { preflightDone = () => resolve(); });
		const run = agent.session.prompt(text, { expandPromptTemplates: false, preflightResult: preflightDone });
		const tracked = run.then(() => {
			if (agent.runNumber === runNumber && agent.publishedRun < runNumber) finishRun(agent);
		}).catch((error: unknown) => {
			if (agent.destroyed || agent.runNumber !== runNumber || agent.publishedRun >= runNumber) return;
			agent.status = agent.abortRequested ? "aborted" : "failed";
			publish(agent, agent.abortRequested ? "Child run aborted." : `Child run failed: ${errorText(error)}`);
			changed();
		}).finally(() => {
			preflightDone();
			if (agent.runPromise === tracked) {
				agent.runPromise = undefined;
				agent.preflight = undefined;
			}
		});
		agent.runPromise = tracked;
	}

	async function send(agent: Child, text: string): Promise<void> {
		if (agent.destroyed) return;
		if (agent.status === "waiting") throw new Error("Answer the pending question first");
		if (agent.session.isStreaming || agent.status === "running") {
			await agent.session.steer(text);
			changed();
		} else {
			startRun(agent, text);
		}
	}

	async function abort(agent: Child): Promise<void> {
		if (agent.destroyed || (agent.status !== "running" && agent.status !== "waiting")) return;
		agent.abortRequested = true;
		answerQuestion(agent, { answer: null, error: "Question aborted" });
		await agent.preflight;
		await agent.session.abort();
		await agent.runPromise;
		if (agent.publishedRun < agent.runNumber) finishRun(agent);
		changed();
	}

	async function destroy(agent: Child): Promise<void> {
		if (agent.destroyed) return;
		agent.destroyed = true;
		answerQuestion(agent, { answer: null, error: "Agent deleted" });
		try {
			await agent.preflight;
			await agent.session.abort();
			await agent.runPromise;
			await agent.session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" });
		} finally {
			agent.unsubscribe();
			agent.session.dispose();
			agents.delete(agent.name);
			reserved.delete(agent.name);
			changed();
		}
	}

	pi.on("session_start", (_event, ctx) => {
		parent = ctx;
		alive = true;
		changed();
	});
	pi.on("session_shutdown", async (_event, ctx) => {
		alive = false;
		ctx.ui.setStatus("subagents", undefined);
		parent = undefined;
		pendingResults.length = 0;
		await Promise.allSettled([...agents.values()].map(destroy));
		listeners.clear();
	});

	pi.registerTool({
		name: "delegate",
		label: "Delegate",
		description: "Start a concurrent in-process child agent. Set agent to planner to use a planning profile. Project profiles in .pi/agents require saved project trust and take precedence over user profiles. Profiles may specify a prompt template. The user chooses its model and thinking level in fuzzy TUI pickers. Results appear in the parent when the child finishes; use /agent to talk to it.",
		promptSnippet: "Start a concurrent child agent; set agent to planner for planning. The user selects its model and thinking level",
		parameters: Type.Object({
			task: Type.String({ minLength: 1, description: "Task for the child agent" }),
			agent: Type.Optional(Type.String({ description: "User or trusted project agent profile name, such as planner" })),
		}),
		async execute(_id, params, signal, _update, ctx) {
			if (ctx.mode !== "tui") throw new Error("delegate requires an interactive Pi TUI in v1");
			if (!alive || signal?.aborted) throw new Error("Delegation cancelled");
			const task = params.task.trim();
			if (!task) throw new Error("Provide a task for the child agent");
			const profile = params.agent === undefined ? undefined : loadProfile(params.agent, ctx);
			const currentProvider = ctx.model?.provider;
			const currentModelId = ctx.model?.id;
			const available = ctx.modelRegistry.getAvailable().sort((a, b) => {
				const aCurrent = a.provider === currentProvider && a.id === currentModelId;
				const bCurrent = b.provider === currentProvider && b.id === currentModelId;
				return Number(bCurrent) - Number(aCurrent) || `${a.provider}/${a.id}`.localeCompare(`${b.provider}/${b.id}`);
			});
			if (!available.length) throw new Error("No authenticated models available for delegation");
			const model = await pick(ctx, "model", available, (item) => `${item.provider}/${item.id}`, signal);
			if (!model) return { content: [{ type: "text", text: "Delegation cancelled; no child started." }] };
			const levels = getSupportedThinkingLevels(model).sort((a, b) =>
				Number(b === ctx.thinkingLevel) - Number(a === ctx.thinkingLevel),
			);
			const thinking = await pick(ctx, "thinking level", levels, (level) => level, signal);
			if (!thinking) return { content: [{ type: "text", text: "Delegation cancelled; no child started." }] };
			if (!alive || signal?.aborted) throw new Error("Delegation cancelled");
			const provider = model.provider;
			const modelId = model.id;
			const name = NAMES.find((candidate) => !reserved.has(candidate));
			if (!name) throw new Error("All ten child sessions are occupied; delete one with /agent");
			reserved.add(name);
			let session: AgentSession | undefined;
			try {
				const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
				if (!auth.ok) throw new Error(auth.error);
				const runtime = await ModelRuntime.create();
				// A child has its own SDK runtime. Copy providers registered dynamically by the parent.
				for (const id of ctx.modelRegistry.getRegisteredProviderIds()) {
					const native = ctx.modelRegistry.getRegisteredNativeProvider(id);
					const config = ctx.modelRegistry.getRegisteredProviderConfig(id);
					if (native) runtime.registerNativeProvider(native);
					if (config) runtime.registerProvider(id, config);
				}
				// OAuth credentials must remain refreshable in the child's runtime.
				if (auth.apiKey && !ctx.modelRegistry.isUsingOAuth(model)) {
					await runtime.setRuntimeApiKey(provider, auth.apiKey);
				}
				let childModel = runtime.getModel(provider, modelId);
				if (!childModel) {
					const refresh = await runtime.refresh({ providers: [provider], allowNetwork: true, force: true, signal });
					if (refresh.aborted || signal?.aborted) throw new Error("Delegation cancelled");
					childModel = runtime.getModel(provider, modelId);
				}
				if (!childModel) throw new Error(`Model unavailable in child runtime: ${provider}/${modelId}`);
				const settings = SettingsManager.create(ctx.cwd, getAgentDir(), { projectTrusted: ctx.isProjectTrusted() });
				const loader = new DefaultResourceLoader({
					cwd: ctx.cwd, agentDir: getAgentDir(), settingsManager: settings,
					appendSystemPromptOverride: profile?.instructions ? (base) => [...base, profile.instructions] : undefined,
				});
				await loader.reload();
				let prompt = task;
				if (profile?.template) {
					const globalPath = join(getAgentDir(), "prompts", `${profile.template}.md`);
					const projectPath = join(ctx.cwd, CONFIG_DIR_NAME, "prompts", `${profile.template}.md`);
					const paths = profile.source === "project" ? [projectPath, globalPath] : [globalPath];
					const template = paths.map((path) => loader.getPrompts().prompts.find((item) => item.name === profile.template && item.filePath === path)).find(Boolean);
					if (!template) throw new Error(`Agent ${profile.name} requires a prompt template at ${paths.join(" or ")}`);
					if (!template.content.includes("$ARGUMENTS")) throw new Error(`Prompt template ${template.filePath} must contain $ARGUMENTS`);
					// Expand only the template, preserving quotes and newlines in the task verbatim.
					prompt = template.content.replaceAll("$ARGUMENTS", task);
				}

				let child!: Child;
				const ask = defineTool({
					name: "ask_question",
					label: "Ask Question",
					description: "Ask the user one question with meaningful options or a custom answer. Wait for their answer in /agent.",
					promptSnippet: "Ask the user one question and wait for their answer in /agent",
					promptGuidelines: [
						"Use ask_question when clarification is needed; the user answers through /agent. Do not wait for a new user message.",
						"Ask one focused question with meaningful options, putting the recommended option first.",
					],
					executionMode: "sequential",
					parameters: questionParameters,
					execute(_callId, input, questionSignal) {
						const question = input.question.trim();
						const options = input.options.map((option) => ({ label: option.label.trim(), description: option.description?.trim() }));
						const error = questionError(question, options);
						const details = { question, options: options.map((option) => option.label), answer: null };
						if (error || child.destroyed || questionSignal?.aborted) {
							return Promise.resolve(questionResult({ ...details, error: error ?? "Question aborted" }));
						}
						if (child.pending) return Promise.resolve(questionResult({ ...details, error: "Question already pending" }));
						return new Promise<ReturnType<typeof questionResult>>((resolve) => {
							const onAbort = () => answerQuestion(child, { answer: null, error: "Question aborted" });
							child.pending = { params: { question, options }, resolve, signal: questionSignal, onAbort };
							child.status = "waiting";
							questionSignal?.addEventListener("abort", onAbort, { once: true });
							if (questionSignal?.aborted) onAbort();
							else {
								ctx.ui.notify(`${name} is waiting for an answer. Open /agent ${name}.`, "info");
								changed();
							}
						});
					},
				});
				const created = await createAgentSession({
					cwd: ctx.cwd, model: childModel, thinkingLevel: thinking, modelRuntime: runtime,
					settingsManager: settings, resourceLoader: loader,
					sessionManager: SessionManager.inMemory(ctx.cwd),
					tools: pi.getActiveTools().filter((tool) => tool !== "delegate"),
					excludeTools: ["delegate"], customTools: [ask],
				});
				session = created.session;
				await session.bindExtensions({ mode: "print" });
				session.setThinkingLevel(thinking);
				if (session.thinkingLevel !== thinking) throw new Error(`Model does not support thinking level ${thinking}`);
				if (!alive || signal?.aborted) throw new Error("Delegation cancelled");
				child = {
					name, profile: profile?.name, task, model: `${provider}/${modelId}`, thinking,
					session, status: "running", createdAt: Date.now(), runNumber: 0, publishedRun: 0,
					abortRequested: false, destroyed: false, unsubscribe: () => {},
				};
				child.unsubscribe = session.subscribe((event) => {
					if (event.type === "agent_settled") finishRun(child);
					else changed();
				});
				agents.set(name, child);
				changed();
				startRun(child, prompt);
				return { content: [{ type: "text", text: `Started ${name}${profile ? ` (${profile.name})` : ""}: ${child.model} / ${child.thinking}. Use /agent ${name} to view or answer questions.` }], details: { name, ...(profile ? { profile: profile.name } : {}) } };
			} catch (error) {
				try {
					if (session) {
						try {
							await session.abort();
							await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" });
						} finally { session.dispose(); }
					}
				} finally { reserved.delete(name); }
				throw error;
			}
		},
	});

	pi.registerCommand("agent", {
		description: "Pick, enter, or delete a retained child agent; /agent Joe opens Joe directly",
		getArgumentCompletions: (prefix) => NAMES.filter((name) => agents.has(name) && name.toLowerCase().startsWith(prefix.toLowerCase())).map((name) => ({ value: name, label: name })),
		async handler(args, ctx) {
			if (ctx.mode !== "tui") { ctx.ui.notify("/agent needs the interactive TUI", "error"); return; }
			if (!agents.size) { ctx.ui.notify("No child agents. Use delegate first.", "info"); return; }
			let name = [...agents.keys()].find((candidate) => candidate.toLowerCase() === args.trim().toLowerCase());
			if (args.trim() && !name) { ctx.ui.notify(`No agent named ${args.trim()}`, "error"); return; }
			if (!name) {
				name = await ctx.ui.custom<AgentName | undefined>((tui, theme, keys, done) => {
					const search = new Input({ prompt: " > ", placeholder: "Search agents" });
					let selected = 0;
					let confirmDelete: AgentName | undefined;
					let deleting = false;
					function remove(agent: Child): void {
						deleting = true;
						void destroy(agent)
							.catch((error: unknown) => ctx.ui.notify(`Could not delete ${agent.name}: ${errorText(error)}`, "error"))
							.finally(() => { deleting = false; redraw(); });
					}
					const matches = () => {
						const groups = [...agents.values()].sort((a, b) => priority(a.status) - priority(b.status) || a.createdAt - b.createdAt);
						const text = (a: Child) => `${a.name} ${a.task} ${a.model} ${a.thinking} ${a.status}`;
						return [0, 1, 2, 3].flatMap((group) => fuzzyFilter(groups.filter((a) => priority(a.status) === group), search.getValue(), text));
					};
					const redraw = () => tui.requestRender();
					listeners.add(redraw);
					const component: { focused: boolean; render(width: number): string[]; handleInput(data: string): void; invalidate(): void; dispose(): void } & Focusable = {
						get focused() { return search.focused; },
						set focused(value) { search.focused = value; },
						render(width) {
							const list = matches();
							selected = Math.max(0, Math.min(selected, list.length - 1));
							const lines = [
								...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width),
								...new Text(theme.fg("accent", theme.bold("agents")), 1, 0).render(width),
								...search.render(width),
							];
							const start = Math.max(0, Math.min(selected - 3, list.length - 8));
							for (const [index, agent] of list.slice(start, start + 8).entries()) {
								const label = `${index + start === selected ? ">" : " "} ${icon(agent.status)} ${agent.name}  ${agent.task}  ${agent.model}  ${agent.thinking}`;
								lines.push(...new Text(theme.fg(index + start === selected ? "accent" : "text", label), 1, 0).render(width).slice(0, 1));
							}
							if (!list.length) lines.push(...new Text(theme.fg("muted", "No matches"), 1, 0).render(width));
							const help = deleting ? "Deleting..." : confirmDelete
								? `Delete running agent ${confirmDelete}? Enter confirm · Esc cancel`
								: "↑↓ select · Enter open · Ctrl-D delete · Esc back";
							lines.push(...new Text(theme.fg("dim", help), 1, 0).render(width));
							lines.push(...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width));
							return lines;
						},
						handleInput(data) {
							if (deleting) return;
							if (confirmDelete) {
								if (keys.matches(data, "tui.select.confirm")) {
									const agent = agents.get(confirmDelete);
									confirmDelete = undefined;
									if (agent) remove(agent);
								} else confirmDelete = undefined;
								redraw();
								return;
							}
							const list = matches();
							if (keys.matches(data, "tui.select.cancel")) done(undefined);
							else if (keys.matches(data, "tui.select.up")) selected = Math.max(0, selected - 1);
							else if (keys.matches(data, "tui.select.down")) selected = Math.min(list.length - 1, selected + 1);
							else if (keys.matches(data, "app.session.delete")) {
								const agent = list[selected];
								if (agent && (agent.status === "running" || agent.status === "waiting")) confirmDelete = agent.name;
								else if (agent) remove(agent);
							} else if (keys.matches(data, "tui.select.confirm")) {
								if (list[selected]) done(list[selected].name);
							} else { search.handleInput(data); selected = 0; }
							redraw();
						},
						invalidate() { search.invalidate(); },
						dispose() { listeners.delete(redraw); },
					};
					return component;
				}, { overlay: true });
			}
			const agent = name && agents.get(name);
			if (!agent) return;
			await ctx.ui.custom<void>((tui, theme, keys, done) => {
				const input = new Input({ prompt: " > ", placeholder: "Message child" });
				let selected = 0;
				let phase: "choices" | "custom" | "comment" = "choices";
				let question: PendingQuestion | undefined;
				let scroll = 0;
				let notice: string | undefined;
				const redraw = () => tui.requestRender();
				listeners.add(redraw);
				function syncQuestion(): void {
					if (question === agent.pending) return;
					question = agent.pending;
					selected = 0;
					phase = "choices";
					input.setValue("");
				}
				function submit(value: string): void {
					const text = value.trim();
					if (!text && phase !== "comment") return;
					if (question && phase === "custom") answerQuestion(agent, { answer: text, wasCustom: true });
					else if (question && phase === "comment") answerQuestion(agent, { answer: question.params.options[selected]!.label, selectedIndex: selected + 1, comment: text || undefined });
					else if (!question) void send(agent, text).catch((error: unknown) => { notice = errorText(error); redraw(); });
					input.setValue("");
					redraw();
				}
				input.onSubmit = submit;
				return {
					get focused() { return input.focused; },
					set focused(value: boolean) { input.focused = value; },
					render(width: number): string[] {
						syncQuestion();
						const header = [
							...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width),
							...new Text(theme.fg("accent", `${agent.name} · ${agent.model} · ${agent.thinking} · ${agent.status}`), 1, 0).render(width),
						];
						const footer: string[] = [];
						if (question) {
							footer.push(...new Text(theme.fg("warning", question.params.question), 1, 0).render(width));
							if (phase === "choices") {
								const choices = questionChoices(question.params.options);
								const start = Math.max(0, Math.min(selected - 2, choices.length - 6));
								for (const [index, choice] of choices.slice(start, start + 6).entries()) {
									const line = `${index + start === selected ? ">" : " "} ${choice.label}${choice.description ? ` — ${choice.description}` : ""}`;
									footer.push(...new Text(theme.fg(index + start === selected ? "accent" : "text", line), 1, 0).render(width).slice(0, 1));
								}
							} else footer.push(...new Text(theme.fg("dim", phase === "custom" ? CUSTOM_OPTION_LABEL : "Add details (Enter to submit, Esc to return)"), 1, 0).render(width));
						}
						if (notice) footer.push(...new Text(theme.fg("error", notice), 1, 0).render(width));
						if (!question || phase !== "choices") footer.push(...input.render(width));
						footer.push(...new Text(theme.fg("dim", question && phase === "choices"
							? "↑↓ choose · Enter answer · Tab add details · Esc back · Ctrl-C abort"
							: "PgUp/PgDn scroll · Enter send · Esc back · Ctrl-C abort"), 1, 0).render(width));
						footer.push(...new DynamicBorder((s: string) => theme.fg("accent", s)).render(width));
						const height = Math.max(1, tui.terminal.rows - header.length - footer.length);
						let transcript: string[] = [];
						const messages = agent.session.messages;
						const streaming = agent.session.agent.state.streamingMessage;
						for (let index = messages.length; index >= 0 && transcript.length < height + scroll; index--) {
							const message = index === messages.length ? (streaming?.role === "assistant" ? streaming : undefined) : messages[index];
							if (!message) continue;
							const rendered: string[] = [];
							if (message.role === "user") rendered.push(...new Text(theme.fg("accent", "user") + "\n" + String(typeof message.content === "string" ? message.content : message.content.filter((p) => p.type === "text").map((p) => p.text).join("\n")), 1, 0).render(width));
							else if (message.role === "assistant") {
								for (const part of message.content) {
									if (part.type === "text") rendered.push(...new Text(theme.fg("success", "assistant") + "\n" + part.text, 1, 0).render(width));
									else if (part.type === "thinking") rendered.push(...new Text(theme.fg("dim", `thinking: ${part.thinking}`), 1, 0).render(width));
									else if (part.type === "toolCall") rendered.push(...new Text(theme.fg("muted", `tool: ${part.name}(${JSON.stringify(part.arguments)})`), 1, 0).render(width));
								}
							} else if (message.role === "toolResult") rendered.push(...new Text(theme.fg(message.isError ? "error" : "muted", `${message.toolName}: ${message.content.filter((p) => p.type === "text").map((p) => p.text).join(" ").slice(0, 500)}`), 1, 0).render(width));
							transcript = [...rendered, ...transcript];
						}
						scroll = Math.min(scroll, Math.max(0, transcript.length - height));
						const visible = transcript.slice(Math.max(0, transcript.length - height - scroll), transcript.length - scroll || undefined);
						if (!transcript.length) visible.push(...new Text(theme.fg("dim", "Waiting for child output..."), 1, 0).render(width));
						return [...header, ...visible, ...Array(Math.max(0, height - visible.length)).fill(""), ...footer]
							.map((line) => truncateToWidth(line, width, ""));
					},
					handleInput(data: string): void {
						syncQuestion();
						if (matchesKey(data, Key.ctrl("c"))) {
							void abort(agent).catch((error: unknown) => { notice = errorText(error); redraw(); });
						} else if (keys.matches(data, "tui.select.cancel")) {
							if (phase !== "choices") { phase = "choices"; input.setValue(""); }
							else done();
						} else if (keys.matches(data, "tui.select.pageUp")) scroll += 10;
						else if (keys.matches(data, "tui.select.pageDown")) scroll = Math.max(0, scroll - 10);
						else if (question && phase === "choices") {
							const max = question.params.options.length;
							if (keys.matches(data, "tui.select.up")) selected = (selected + max) % (max + 1);
							else if (keys.matches(data, "tui.select.down")) selected = (selected + 1) % (max + 1);
							else if (keys.matches(data, "tui.select.confirm") || keys.matches(data, "tui.input.tab")) {
								if (selected === max) phase = "custom";
								else if (keys.matches(data, "tui.input.tab")) phase = "comment";
								else answerQuestion(agent, { answer: question.params.options[selected]!.label, selectedIndex: selected + 1 });
							}
						} else input.handleInput(data);
						redraw();
					},
					invalidate() { input.invalidate(); },
					dispose() { listeners.delete(redraw); },
				};
			}, { overlay: true, overlayOptions: { width: "100%", maxHeight: "100%", anchor: "top-left" } });
		},
	});
}
