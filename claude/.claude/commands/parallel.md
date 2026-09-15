Run multiple tasks in parallel with explicit task list.

Tasks: $ARGUMENTS

## Step 1: Parse Tasks

Each quoted string or line is a separate task.

## Step 2: Analyze for Conflicts

Before spawning, check if tasks might conflict:
- Identify likely files per task
- Check for overlapping targets

If conflicts detected, warn and offer options:
1. Proceed anyway
2. Merge conflicting tasks
3. Run conflicting tasks sequentially

## Step 3: Spawn All Agents

**CRITICAL: All Agent calls in ONE message for true parallelism.**

For each task, use the Agent tool:
```
Agent(
  description="Parallel: <task summary>",
  prompt="<full task description with context>"
)
```

## Step 4: Collect and Report

```markdown
## Parallel Execution Complete

| # | Task | Status | Summary |
|---|------|--------|---------|
| 1 | <task> | done | <summary> |
| 2 | <task> | done | <summary> |

### Failed Tasks
[Details on any failures]

### Next Steps
[If any tasks failed, suggest remediation]
```
