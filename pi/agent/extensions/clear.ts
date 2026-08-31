import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Clear the conversation and start a fresh session",
    handler: async (_args, ctx) => {
      await ctx.newSession();
    },
  });
}
