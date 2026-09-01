import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type SavedState = {
  provider: string;
  model: string;
  thinking: ReturnType<ExtensionAPI["getThinkingLevel"]>;
};

const state = globalThis as typeof globalThis & {
  __piKeepModelOnNew?: SavedState;
};

export default function (pi: ExtensionAPI) {
  pi.on("session_shutdown", async (event, ctx) => {
    if (event.reason !== "new" || !ctx.model)
      return;

    state.__piKeepModelOnNew = {
      provider: ctx.model.provider,
      model: ctx.model.id,
      thinking: pi.getThinkingLevel(),
    };
  });

  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "new")
      return;

    const saved = state.__piKeepModelOnNew;
    delete state.__piKeepModelOnNew;

    if (!saved)
      return;

    const model = ctx.modelRegistry.find(saved.provider, saved.model);
    if (!model)
      return;

    await pi.setModel(model);
    pi.setThinkingLevel(saved.thinking);
  });
}
