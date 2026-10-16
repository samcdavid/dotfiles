/**
 * Bell Plugin (TUI half)
 *
 * Rings the terminal bell (BEL, \a) on the current tmux pane when OpenCode
 * is waiting on the user — the same tmux-targeted bell command Claude Code,
 * Codex, and pi (agent/extensions/bell.ts) already run, so OpenCode triggers
 * the same monitor-bell window highlight in tmux.conf.
 *
 * This has to run in the TUI, not the server: every OpenCode TUI attaches to
 * one shared background server (`opencode serve --service`), whose
 * TMUX_PANE is whichever pane first started it — so a server-side bell
 * always lands in that one pane. Each TUI process carries its own pane.
 *
 * Per-TUI is not enough on its own: every TUI also receives the events of
 * every session on that shared server, so each bell is gated on the event's
 * session belonging to this TUI (the open route or a session tab). Without
 * the gate, one session's prompt rings every pane running OpenCode.
 *
 * Written against the OpenCode 2.x TUI plugin runtime (verified on 2.0.25),
 * whose published docs and @opencode-ai/plugin typings still describe the
 * 1.x API. The context shape and event names mirror the built-in
 * `opencode.notifications` TUI plugin. Its attention sounds play audio, not
 * BEL, so tmux never sees them.
 */

import { execFile } from "node:child_process";

type BusEvent = {
	data: { sessionID?: string; form?: { sessionID?: string } };
};

type TuiContext = {
	data: {
		on(type: string, handler: (event: BusEvent) => void): () => void;
		session: {
			get(sessionID: string): { parentID?: string } | undefined;
			root(sessionID: string): string;
		};
	};
	ui: {
		router: { current(): { type: string; sessionID?: string } };
		tabs: { enabled(): boolean; list(): { sessionID: string }[] };
	};
};

function ringBell(): void {
	if (!process.env.TMUX_PANE) return;
	const command = `printf '\\a' > "$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')" 2>/dev/null; true`;
	execFile("/bin/sh", ["-c", command], () => {});
}

export default {
	id: "bell",
	setup(ctx: TuiContext) {
		// Compared by root session so a subagent's permission prompt still rings
		// the TUI that owns its parent.
		const isShownHere = (sessionID: string) => {
			const shown: string[] = [];
			const route = ctx.ui.router.current();
			if (route.type === "session" && route.sessionID) shown.push(route.sessionID);
			if (ctx.ui.tabs.enabled()) {
				shown.push(...ctx.ui.tabs.list().map((tab) => tab.sessionID));
			}
			const root = ctx.data.session.root(sessionID);
			return shown.some((id) => ctx.data.session.root(id) === root);
		};
		const ringIfShown = (sessionID: string | undefined) => {
			if (sessionID && isShownHere(sessionID)) ringBell();
		};
		// Subagent (child) sessions finish while the parent is still working;
		// only a top-level session finishing means OpenCode is actually waiting
		// on the user. Interrupted is skipped because the user just pressed the
		// key and is already there.
		const ringIfTopLevel = (event: BusEvent) => {
			const sessionID = event.data.sessionID;
			if (sessionID && !ctx.data.session.get(sessionID)?.parentID) {
				ringIfShown(sessionID);
			}
		};
		const unsubscribe = [
			ctx.data.on("permission.asked", (event) => ringIfShown(event.data.sessionID)),
			// The question tool surfaces as a form in 2.x.
			ctx.data.on("form.created", (event) => ringIfShown(event.data.form?.sessionID)),
			ctx.data.on("session.execution.succeeded", ringIfTopLevel),
			ctx.data.on("session.execution.failed", ringIfTopLevel),
		];
		return () => unsubscribe.forEach((dispose) => dispose());
	},
};
