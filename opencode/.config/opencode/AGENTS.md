## Code Comments
Do not litter the codebase with redundant code comments. Only leave comments for things that are not easily explainable by reading the code. The code should speak for itself.

## Commits
Always commit work in small chunks using conventional commit messages. Do not write an essay in the messages.

## Lint Is Law

Fix all lint errors before commit. No "pre-existing" excuses.

## Tooling Priority

Prefer plugin tools over raw CLI/MCP.

1. Read/Edit tools
2. ast-grep
3. Glob/Grep
4. Task subagents
5. Bash (system commands only)

## OpenCode Rules

- `AGENTS.md` files are merged; nearest directory scope wins. Global rules live in `~/.config/opencode/AGENTS.md`.
- `/init` generates or extends `AGENTS.md`; commit it for the team.
- `opencode.json` can load extra instructions via `instructions` (files, globs, or URLs); these merge with `AGENTS.md`.
- Config sources merge (not replace). Precedence: remote `.well-known/opencode` → global `~/.config/opencode/opencode.json` → `OPENCODE_CONFIG` → project `opencode.json` → `.opencode` dirs → `OPENCODE_CONFIG_CONTENT`.

## Permissions

- Use `permission` rules with `allow` / `ask` / `deny`; the last matching rule wins.
- `.env` reads are denied by default (`*.env`, `*.env.*`), except `*.env.example`.
- Use the **Plan** agent for analysis-only work; it asks before edits or bash.

## MCP

- Manage servers with `opencode mcp add|list|auth|logout|debug`.
- Enable only the MCPs you need to limit context bloat.

## Formatters

- OpenCode auto-runs formatters after edits; ensure formatter deps/configs exist.

## Communication Style

Direct. Terse. No fluff. Disagree when wrong. Remember that you are an LLM model, you don't get tired, you execute tasks much faster than humans.

## Project Management and Planning

Your estimates should be based on your ability to execute, not human's abilities. What could take a team of humans weeks to break down into multiple phases of delivery takes you orders of magnitude less. Avoid "phased" releases unless explicitly asked, always assume that all work should be done immediately.

## Documentation Style

Use JSDoc for components and functions.

## Knowledge Files (Load on demand)

- `@knowledge/error-patterns.md`
- `@knowledge/prevention-patterns.md`
- `@knowledge/mastra-agent-patterns.md`

## Code Philosophy

- Simple over complex. Explicit over implicit.
- Server first, client when necessary.
- Composition > inheritance.
- Make impossible states impossible.
- Don’t abstract until the third use.
