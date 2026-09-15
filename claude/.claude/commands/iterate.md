Evaluator-optimizer loop - generate, critique, improve until quality threshold met.

Target: $ARGUMENTS

## The Pattern

```
Generator (create) → Evaluator (critique) → Optimizer (improve) → loop
```

Default: max 3 rounds, exit early if score >= 8/10.

## Step 1: Parse Arguments

- `--max-rounds N` (default: 3)
- `--criteria "..."` (quality criteria, or use defaults)
- The task description

Default criteria:
- Type-safe (no `any`, proper inference)
- No obvious bugs or edge cases
- Follows existing patterns in codebase
- Readable and maintainable

## Step 2: Initial Generation

Generate the first version (new code, refactored code, or design).

## Step 3: Evaluation Loop

For each round:

### Evaluate (spawn reviewer agent)
Use the Agent tool to spawn a code review agent:
- Score each criterion (1-10)
- Overall score (1-10)
- Specific issues with file:line references
- Concrete suggestions for improvement
- If overall >= 8, APPROVED

### Check for Approval
If approved or max rounds reached, exit loop.

### Optimize
Apply evaluator's suggestions, then loop back.

## Step 4: Final Report

```markdown
## Iteration Complete

### Rounds: N | Final Score: X/10

| Round | Score | Key Changes |
|-------|-------|-------------|
| 1 | 5 | Initial implementation |
| 2 | 7 | Fixed null handling, added types |
| 3 | 8 | Added edge case tests |

### Remaining Issues (if any)
- [minor issues that didn't block approval]

### Files Changed
- [list]
```
