import { dirname, isAbsolute, relative, resolve, sep } from "node:path";
import { realpath } from "node:fs/promises";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Guardrail for interactive Pi sessions, not a sandbox.
 *
 * Direct write/edit calls may only target the current worktree (and never its
 * .git metadata). Bash is inherently hard to analyse, so this also blocks
 * obvious host/admin commands and asks before common destructive operations.
 */
export default function (pi: ExtensionAPI) {
	async function canonicalPath(path: string): Promise<string> {
		let candidate = resolve(path);
		while (true) {
			try {
				const existing = await realpath(candidate);
				return resolve(existing, relative(candidate, resolve(path)));
			} catch {
				const parent = dirname(candidate);
				if (parent === candidate) return resolve(path);
				candidate = parent;
			}
		}
	}

	function isInside(path: string, root: string): boolean {
		const rel = relative(root, path);
		return rel === "" || (!rel.startsWith(`..${sep}`) && rel !== ".." && !isAbsolute(rel));
	}

	function block(reason: string, ctx: { hasUI: boolean; ui: { notify(message: string, level: "warning"): void } }) {
		if (ctx.hasUI) ctx.ui.notify(reason, "warning");
		return { block: true, reason };
	}

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName === "write" || event.toolName === "edit") {
			const requested = event.input.path as string;
			const root = await canonicalPath(ctx.cwd);
			const target = await canonicalPath(resolve(ctx.cwd, requested));
			const rel = relative(root, target);

			if (!isInside(target, root)) {
				return block(`Blocked ${event.toolName} outside this worktree: ${requested}`, ctx);
			}
			if (rel === ".git" || rel.startsWith(`.git${sep}`)) {
				return block(`Blocked ${event.toolName} to Git metadata: ${requested}`, ctx);
			}
			return undefined;
		}

		if (event.toolName !== "bash") return undefined;
		const command = event.input.command as string;

		// Never permit privilege escalation or commands that are normally
		// machine-destructive. Run such work manually, outside Pi.
		if (/\b(?:sudo|doas|pkexec)\b/i.test(command)) {
			return block("Blocked privilege-escalation command", ctx);
		}
		if (/\b(?:dd|mkfs(?:\.[\w-]+)?|mount|umount|shutdown|reboot|poweroff)\b/i.test(command)) {
			return block("Blocked machine-level command", ctx);
		}
		if (/(?:^|[\s;|&])(?:cd|pushd)\s+(?:\.\.|\/|~|\$HOME|\$\{HOME\})/m.test(command)) {
			return block("Blocked bash command that leaves the worktree", ctx);
		}
		if (/(?:^|[\s;|&])(?:rm|mv|cp|chmod|chown)\b[^\n]*(?:\s~(?:\/|$)|\s\/(?:etc|usr|var|root|boot)(?:\/|$))/m.test(command)) {
			return block("Blocked bash command targeting a protected host path", ctx);
		}

		const needsConfirmation = [
			/\brm\s+(?:[^\n]*\s)?(?:-[^\s]*[rf]|--(?:recursive|force))/i,
			/\bgit\s+clean\b/i,
			/\b(?:chmod|chown)\s+(?:-R|--recursive)\b/i,
		].some((pattern) => pattern.test(command));

		if (!needsConfirmation) return undefined;
		if (!ctx.hasUI) return { block: true, reason: "Destructive command blocked without UI" };
		const allowed = await ctx.ui.confirm("Destructive shell command", command);
		return allowed ? undefined : { block: true, reason: "Blocked by worktree guard" };
	});
}
