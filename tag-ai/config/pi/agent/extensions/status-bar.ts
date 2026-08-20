import { isAbsolute, relative, resolve, sep as pathSep } from "node:path";

import type { Usage } from "@earendil-works/pi-ai";
import {
	SettingsManager,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/*
 * Single-line Pi footer.
 *
 * Layout follows the user's tmux/Waybar style, with a generic
 * dark-theme palette:
 *   accent   #d77757
 *   foreground     #c1c1c1
 *   muted          #999999
 *   subtle         #505050
 *   success        #4eba65
 *   warning        #ffc107
 *   error          #ff6b80
 *
 * The footer keeps the information from Pi's stock footer on one physical line:
 * cwd, git branch, session name, cumulative usage, latest cache-hit rate,
 * cost/subscription marker, context/window + auto-compaction marker, xp,
 * extension statuses, provider/model, and thinking level.
 */

const SEP = "  ";
const ELLIPSIS = "…";
const RESET = "\x1b[0m";

const PALETTE = {
	accent: "d77757",
	foreground: "c1c1c1",
	muted: "999999",
	subtle: "505050",
	success: "4eba65",
	warning: "ffc107",
	error: "ff6b80",
	white: "ffffff",
} as const;

function fg(hex: string, text: string): string {
	const [r, g, b] = hex.match(/../g)!.map((v) => Number.parseInt(v, 16));
	return `\x1b[38;2;${r};${g};${b}m${text}${RESET}`;
}

function active(text: string): string {
	// Path in accent foreground (no background block).
	return fg(PALETTE.accent, ` ${text} `);
}

const strong = (text: string) => fg(PALETTE.white, text);
const primary = (text: string) => fg(PALETTE.foreground, text);
const muted = (text: string) => fg(PALETTE.muted, text);
const dim = (text: string) => fg(PALETTE.subtle, text);
const warning = (text: string) => fg(PALETTE.warning, text);
const error = (text: string) => fg(PALETTE.error, text);
const separator = () => dim(SEP);

interface UsageTotals {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	latestCacheHitRate?: number;
}

function addUsage(totals: UsageTotals, usage: Usage | undefined): void {
	if (!usage) return;
	totals.input += usage.input ?? 0;
	totals.output += usage.output ?? 0;
	totals.cacheRead += usage.cacheRead ?? 0;
	totals.cacheWrite += usage.cacheWrite ?? 0;
	totals.cost += usage.cost?.total ?? 0;
}

function collectUsage(ctx: ExtensionContext): UsageTotals {
	const totals: UsageTotals = {
		input: 0,
		output: 0,
		cacheRead: 0,
		cacheWrite: 0,
		cost: 0,
	};

	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "message") {
			const message = entry.message as { role?: string; usage?: Usage };
			if (message.role === "assistant") {
				addUsage(totals, message.usage);

				if (message.usage) {
					const promptTokens =
						(message.usage.input ?? 0) +
						(message.usage.cacheRead ?? 0) +
						(message.usage.cacheWrite ?? 0);
					totals.latestCacheHitRate =
						promptTokens > 0 ? ((message.usage.cacheRead ?? 0) / promptTokens) * 100 : undefined;
				}
			} else if (message.role === "toolResult") {
				addUsage(totals, message.usage);
			}
		} else if (entry.type === "branch_summary" || entry.type === "compaction") {
			addUsage(totals, (entry as { usage?: Usage }).usage);
		}
	}

	return totals;
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10_000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

function formatCwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (!home) return cwd;

	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(home);
	const relativeToHome = relative(resolvedHome, resolvedCwd);
	const insideHome =
		relativeToHome === "" ||
		(relativeToHome !== ".." &&
			!relativeToHome.startsWith(`..${pathSep}`) &&
			!isAbsolute(relativeToHome));

	if (!insideHome) return cwd;
	return relativeToHome === "" ? "~" : `~${pathSep}${relativeToHome}`;
}

function sanitizeStatus(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function isSubscriptionBacked(ctx: ExtensionContext): boolean {
	const model = ctx.model;
	if (!model) return false;

	// Pi treats Kimi Coding as subscription-backed even though it authenticates
	// with an API-key-shaped credential.
	if (model.provider === "kimi-coding") return true;

	if (!ctx.modelRegistry.isUsingOAuth(model)) return false;
	return ctx.modelRegistry.getProvider(model.provider)?.auth?.oauth?.isSubscription === true;
}

function buildUsage(ctx: ExtensionContext): string {
	const usage = collectUsage(ctx);
	const parts: string[] = [];

	if (usage.input) parts.push(`↑${formatTokens(usage.input)}`);
	if (usage.output) parts.push(`↓${formatTokens(usage.output)}`);
	if (usage.cacheRead) parts.push(`R${formatTokens(usage.cacheRead)}`);
	if (usage.cacheWrite) parts.push(`W${formatTokens(usage.cacheWrite)}`);

	if (
		(usage.cacheRead > 0 || usage.cacheWrite > 0) &&
		usage.latestCacheHitRate !== undefined
	) {
		parts.push(`CH${usage.latestCacheHitRate.toFixed(1)}%`);
	}

	const subscription = isSubscriptionBacked(ctx);
	if (usage.cost || subscription) {
		parts.push(`$${usage.cost.toFixed(3)}${subscription ? " (sub)" : ""}`);
	}

	return muted(parts.join(" "));
}

function buildContext(ctx: ExtensionContext, autoCompactEnabled: boolean): string {
	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
	const percentValue = usage?.percent ?? 0;
	const percent = usage?.percent === null ? "?" : percentValue.toFixed(1);
	const auto = autoCompactEnabled ? " (auto)" : "";
	const label = `${percent}/${formatTokens(contextWindow)}${auto}`;

	// Match Pi's stock thresholds exactly: warning above 70%, error above 90%.
	if (percentValue > 90) return error(label);
	if (percentValue > 70) return warning(label);
	return muted(label);
}

function buildRight(ctx: ExtensionContext, includeProvider: boolean): string {
	const model = ctx.model;
	const modelName = model?.id || "no-model";
	let label = strong(modelName);

	if (model?.reasoning) {
		const thinking = ctx.thinkingLevel || "off";
		label += separator() + muted(thinking === "off" ? "thinking off" : thinking);
	}

	if (includeProvider && model) {
		label = muted(`(${model.provider})`) + " " + label;
	}

	return label;
}

function clipActivePath(path: string, width: number): string {
	if (width <= 0) return "";
	if (width <= 3) return truncateToWidth(active(path), width, dim(ELLIPSIS));

	// active() adds one visible padding cell on each side.
	const inner = truncateToWidth(path, width - 2, ELLIPSIS);
	return active(inner);
}

function renderOneLine(
	path: string,
	identityTail: string,
	telemetry: string,
	rightWithProvider: string,
	rightWithoutProvider: string,
	providerOptional: boolean,
	width: number,
): string {
	if (width <= 0) return "";

	const leftSuffix = identityTail + telemetry;
	let right = rightWithProvider;

	const compose = (pathPart: string, rightPart: string): string => {
		const left = pathPart + leftSuffix;
		const leftWidth = visibleWidth(left);
		const rightWidth = visibleWidth(rightPart);
		const pad = Math.max(1, width - leftWidth - rightWidth);
		return left + " ".repeat(pad) + rightPart;
	};

	let full = compose(active(path), right);
	if (visibleWidth(full) <= width) return full;

	// Stock Pi drops the provider first when there is not enough room.
	if (providerOptional) {
		right = rightWithoutProvider;
		full = compose(active(path), right);
		if (visibleWidth(full) <= width) return full;
	}

	// Preserve the telemetry/model side and shorten the cwd first.
	const suffixWidth = visibleWidth(leftSuffix);
	const rightWidth = visibleWidth(right);
	const pathBudget = width - suffixWidth - rightWidth - 1;
	if (pathBudget >= 4) {
		const clipped = compose(clipActivePath(path, pathBudget), right);
		if (visibleWidth(clipped) <= width) return clipped;
		full = clipped;
	}

	// At very small widths it is mathematically impossible to keep every field.
	// Preserve the model side and truncate the left side as a final fallback.
	const availableLeft = Math.max(0, width - rightWidth - 1);
	if (availableLeft > 0) {
		const left = truncateToWidth(active(path) + leftSuffix, availableLeft, dim(ELLIPSIS));
		const pad = Math.max(1, width - visibleWidth(left) - rightWidth);
		return truncateToWidth(left + " ".repeat(pad) + right, width, dim(ELLIPSIS));
	}

	return truncateToWidth(right, width, "");
}

function loadAutoCompactSetting(ctx: ExtensionContext): boolean {
	try {
		const settings = SettingsManager.create(ctx.cwd, undefined, {
			projectTrusted: ctx.isProjectTrusted(),
		});
		return settings.getCompactionEnabled();
	} catch {
		// Pi's default is enabled. If settings are malformed/unreadable, leave the
		// footer usable rather than making the extension fail to load.
		return true;
	}
}

export default function footerExtension(pi: ExtensionAPI) {
	let requestRender: (() => void) | undefined;
	let autoCompactEnabled = true;

	const redraw = () => requestRender?.();

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		autoCompactEnabled = loadAutoCompactSetting(ctx);

		ctx.ui.setFooter((tui, _theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsubscribeBranch = footerData.onBranchChange(redraw);

			return {
				dispose() {
					unsubscribeBranch();
					requestRender = undefined;
				},

				invalidate() {},

				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const sessionName = ctx.sessionManager.getSessionName();
					const path = formatCwd(ctx.sessionManager.getCwd());

					let identityTail = "";
					if (branch) identityTail += separator() + primary(branch);
					if (sessionName) identityTail += separator() + muted(sessionName);

					const telemetryParts: string[] = [];
					const usage = buildUsage(ctx);
					if (visibleWidth(usage) > 0) telemetryParts.push(usage);
					telemetryParts.push(buildContext(ctx, autoCompactEnabled));

					if (process.env.PI_EXPERIMENTAL === "1") {
						telemetryParts.push(warning("xp"));
					}

					const statuses = Array.from(footerData.getExtensionStatuses().entries())
						.sort(([a], [b]) => a.localeCompare(b))
						.map(([, text]) => sanitizeStatus(text))
						.filter(Boolean);
					if (statuses.length > 0) telemetryParts.push(muted(statuses.join(" ")));

					const telemetry =
						telemetryParts.length > 0 ? separator() + telemetryParts.join(separator()) : "";

					const providerOptional = footerData.getAvailableProviderCount() > 1 && !!ctx.model;
					const rightWithProvider = buildRight(ctx, providerOptional);
					const rightWithoutProvider = buildRight(ctx, false);

					return [
						renderOneLine(
							path,
							identityTail,
							telemetry,
							rightWithProvider,
							rightWithoutProvider,
							providerOptional,
							width,
						),
					];
				},
			};
		});
	});

	// Values used by render() are live. Explicitly request redraws for state
	// changes that may not otherwise invalidate a custom footer component.
	pi.on("model_select", redraw);
	pi.on("thinking_level_select", redraw);
	pi.on("session_info_changed", redraw);
	pi.on("message_end", redraw);
	pi.on("session_compact", redraw);
	pi.on("agent_start", redraw);
	pi.on("agent_end", redraw);
}
