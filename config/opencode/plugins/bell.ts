/**
 * Bell Plugin
 *
 * Rings the terminal bell (BEL, \a) on the current tmux pane when OpenCode
 * is waiting on the user — the same tmux-targeted bell command Claude Code,
 * Codex, and pi (agent/extensions/bell.ts) already run, so OpenCode triggers
 * the same monitor-bell window highlight in tmux.conf.
 *
 * Placement: ~/.config/opencode/plugins/ (global, auto-discovered).
 *
 * Written against the OpenCode 2.x plugin runtime (verified on 2.0.25). Its
 * published docs and @opencode-ai/plugin typings still describe the 1.x
 * `event` hook and `session.idle`, which 2.x no longer loads or emits; the
 * event names below mirror what the built-in TUI attention notifier listens
 * for. OpenCode's own attention sounds play audio, not BEL, so tmux never
 * sees them.
 */

import { execFile } from "node:child_process";

type BusEvent = { type: string; data: { sessionID?: string } };

type PluginContext = {
	event: { subscribe(): AsyncIterable<BusEvent> };
	session: { get(input: { sessionID: string }): Promise<{ parentID?: string }> };
};

function ringBell(): void {
	if (!process.env.TMUX_PANE) return;
	const command = `printf '\\a' > "$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')" 2>/dev/null; true`;
	execFile("/bin/sh", ["-c", command], () => {});
}

async function isTopLevelSession(ctx: PluginContext, sessionID: string | undefined): Promise<boolean> {
	if (!sessionID) return false;
	const session = await ctx.session.get({ sessionID }).catch(() => undefined);
	return session !== undefined && !session.parentID;
}

export default {
	id: "bell",
	setup(ctx: PluginContext) {
		// setup must return for the plugin to finish loading, so the event
		// loop runs detached; it ends on its own when the location shuts down.
		void (async () => {
			for await (const event of ctx.event.subscribe()) {
				switch (event.type) {
					case "permission.asked":
					// The question tool surfaces as a form in 2.x.
					case "form.created":
						ringBell();
						break;
					// Subagent (child) sessions finish while the parent is still
					// working; only a top-level session finishing means OpenCode
					// is actually waiting on the user. Interrupted is skipped
					// because the user just pressed the key and is already there.
					case "session.execution.succeeded":
					case "session.execution.failed":
						if (await isTopLevelSession(ctx, event.data.sessionID)) ringBell();
						break;
				}
			}
		})();
	},
};
