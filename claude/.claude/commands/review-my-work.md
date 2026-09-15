Self-review before PR - lint, types, common mistakes, generate PR description.

## Step 1: Identify What's Changed

Run in parallel:
- `git branch --show-current`
- `git diff main --stat`
- `git diff main --name-only`
- `git log main..HEAD --oneline`

## Step 2: Run the Gauntlet

Run all checks in parallel:
- Type check (tsc --noEmit, cargo check, go vet, etc.)
- Lint (project linter)
- Tests
- Build

## Step 3: Check for Common Mistakes

Scan changed files (via `git diff main --unified=0`) for:
- Console.logs / debug prints (should be removed)
- `any` type annotations
- TODO/FIXME added
- Commented-out code
- Large file additions (1000+ lines)
- .env or secrets files

## Step 4: Review the Diff

Use the Agent tool to spawn a code-reviewer agent:
- Review changes between main and HEAD
- Look for logic errors, missing error handling, security issues, performance concerns, API contract changes

## Step 5: Generate PR Description

```markdown
## Summary
[1-3 bullet points]

## Changes
- [Key change 1]
- [Key change 2]

## Testing
- [ ] Type check passes
- [ ] Lint passes
- [ ] Tests pass
- [ ] Manual testing done
```

## Step 6: Final Checklist

```markdown
## Pre-PR Checklist
- [ ] Branch is rebased on main
- [ ] No type errors
- [ ] No lint errors
- [ ] Tests pass
- [ ] No console.logs
- [ ] No secrets committed
- [ ] PR description written
```
