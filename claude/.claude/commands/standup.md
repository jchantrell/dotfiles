Summarize what changed since last session for standup.

## Step 1: Gather Activity Data

Run in parallel:
- `git log --oneline --since="yesterday" --all`
- `gh pr list --state open --json number,title --jq '.[] | "- PR #\(.number): \(.title)"'`
- `git status --short`

## Step 2: Identify Key Changes

From the git log, identify:
- Features added
- Bugs fixed
- Refactors completed
- Documentation updates

Group commits by type/area.

## Step 3: Generate Standup Report

```markdown
## Standup - [DATE]

### Yesterday / Last Session
- [Completed work items from commits]
- [Key decisions or discoveries]

### Today / Current Focus
- [In-progress work]
- [What to work on next]

### Blockers
- [Any blocked items or external dependencies]

### Open PRs
- [List any PRs awaiting review]

### Metrics
- Commits: [N]
```

Keep it concise - outcomes, not activities.
