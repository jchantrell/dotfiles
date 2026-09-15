Post-mortem on completed work - reflect, extract patterns, close the learning loop.

Context: $ARGUMENTS

## Step 1: Gather Context

Run in parallel:
- `git log --oneline -20`
- `git diff --stat HEAD~10 2>/dev/null || git log --name-only --pretty=format: -10 | sort -u`
- `gh pr list --state merged --json number,title --jq '.[:5][] | "- PR #\(.number): \(.title)"'`

## Step 2: Reconstruct the Journey

1. **Starting Point** - What was the original goal?
2. **Path Taken** - What commits were made? What files changed?
3. **Detours** - Any discovered issues? Scope changes?
4. **Endpoint** - What was actually delivered?

## Step 3: Structured Reflection

### What was the goal?
- Original scope
- Implicit assumptions

### What actually happened?
- Final state vs intended state
- Scope creep or reduction?

### What went well?
- Approaches that worked smoothly
- Good decisions made early

### What went poorly?
- Time sinks / rabbit holes
- Wrong initial assumptions

### What was surprising?
- Unexpected complexity
- Hidden dependencies

### What would you do differently?
- Better starting point or approach

## Step 4: Output

```markdown
## Retro: [topic or date]

### Goal
<what we set out to do>

### Outcome
<what actually happened>

### What Went Well
- **<thing>**: <why it worked>

### What Went Poorly
- **<thing>**: <what went wrong, how to avoid>

### Surprises
- <unexpected discovery>

### Action Items
- [ ] <concrete thing to do differently>
```

The point isn't documentation theater - it's closing the learning loop. Focus on actionable insights.
