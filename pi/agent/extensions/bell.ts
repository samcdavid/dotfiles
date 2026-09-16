/**
 * Bell Extension
 *
 * Rings the terminal bell (BEL, \a) on the current tmux pane when pi has
 * fully settled and is ready for input — the same tmux-targeted bell
 * command Claude Code (Stop/Notification hooks) and Codex (hooks.Stop /
 * hooks.PermissionRequest) already run, so pi triggers the same
 * monitor-bell window highlight in tmux.conf.
 *
 * Placement: ~/.pi/agent/extensions/ (global, auto-discovered).
 */

import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function ringBell(): void {
	if (!process.env.TMUX_PANE) return;
	const command = `printf '\\a' > "$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')" 2>/dev/null; true`;
	execFile("/bin/sh", ["-c", command], () => {});
}

export default function bellExtension(pi: ExtensionAPI) {
	// agent_end may still be followed by auto-retry/compaction/queued
	// follow-ups; agent_settled fires only once pi is truly waiting on the user.
	pi.on("agent_settled", async () => {
		ringBell();
	});
}
