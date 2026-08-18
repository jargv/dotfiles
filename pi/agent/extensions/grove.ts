// Grove agent-status hooks. Installed by 'grove --install-agent-hooks';
// edits will be overwritten on reinstall.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const id = process.env.GROVE_WORKTREE_ID;
	if (!id) return;

	const grove = async (...args: string[]) => {
		try {
			await pi.exec("grove", ["--worktree", id, ...args]);
		} catch {
			// grove not on PATH or exited nonzero — never break the agent.
		}
	};

	pi.on("session_start", () => grove("--status", "stopped"));
	pi.on("agent_start", () => grove("--status", "running"));
	pi.on("agent_settled", () => grove("--status", "stopped"));
	pi.on("session_shutdown", () => grove("--clear"));
}
