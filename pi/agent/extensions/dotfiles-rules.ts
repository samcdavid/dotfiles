/**
 * Dotfiles Rules Extension
 *
 * Claude Code auto-loads every file under ~/.claude/rules/ as always-on
 * global instructions (alongside CLAUDE.md), not just on-demand reference
 * material. Pi has no equivalent behavior for a rules/ directory, so this
 * extension reads every *.md file under ~/.agents/rules/ (the same
 * directory Codex reads, both symlinked from claude/rules/ in the dotfiles
 * repo) and inlines their full text into the system prompt at session
 * start, giving pi the same standing instructions Claude Code and Codex see.
 *
 * Placement: ~/.pi/agent/extensions/ (global, auto-discovered).
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function findMarkdownFiles(dir: string): string[] {
	if (!fs.existsSync(dir)) return [];
	return fs
		.readdirSync(dir, { withFileTypes: true })
		.filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
		.map((entry) => entry.name)
		.sort();
}

export default function dotfilesRulesExtension(pi: ExtensionAPI) {
	const rulesDir = path.join(os.homedir(), ".agents", "rules");
	let ruleFiles: string[] = [];

	pi.on("session_start", async (_event, ctx) => {
		ruleFiles = findMarkdownFiles(rulesDir);
		if (ruleFiles.length > 0) {
			ctx.ui.notify(`Loaded ${ruleFiles.length} global rule(s) from ~/.agents/rules/`, "info");
		}
	});

	pi.on("before_agent_start", async (event) => {
		if (ruleFiles.length === 0) return;

		const rulesText = ruleFiles
			.map((name) => {
				const content = fs.readFileSync(path.join(rulesDir, name), "utf-8").trim();
				return `### ${name}\n\n${content}`;
			})
			.join("\n\n---\n\n");

		return {
			systemPrompt:
				event.systemPrompt +
				`

## Global Rules

The following are standing personal instructions that apply across all projects (same content Claude Code and Codex load automatically from claude/rules/ in the dotfiles repo):

${rulesText}
`,
		};
	});
}
