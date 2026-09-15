Codebase sweep - fix type errors, dead code, lint issues in parallel.

## Step 1: Run Diagnostics

Run these in parallel to identify issues:
- Type errors (tsc --noEmit, cargo check, go vet, etc.)
- Lint issues (if linter configured)
- Stray console.logs/debug prints in src (excluding tests)
- `any` type annotations (TypeScript projects)
- TODO/FIXME/HACK comments

## Step 2: Categorize and Prioritize

1. **Type errors** - must fix, blocks build
2. **Lint errors** - should fix, code quality
3. **Console.logs** - quick wins, remove stray logs
4. **Any casts** - tech debt, fix if straightforward
5. **TODOs** - review, note if still relevant

## Step 3: Fix in Parallel

Use the Agent tool to spawn parallel fixers:
- Group by file - one agent per file
- Type errors first (blocking)
- Skip files with >10 issues (needs manual review)
- Each agent: fix issues, verify compilation, commit

Spawn all file-fix agents in a SINGLE message.

## Step 4: Report

```markdown
## Sweep Complete

### Fixed
- [N] type errors across [M] files
- [N] console.logs removed
- [N] lint issues resolved

### Skipped (needs manual review)
- [file]: [reason]
```
