Get current git context in one shot - branch, status, recent commits, diff stats.

Run all of these in parallel:
- `git branch --show-current`
- `git status -sb`
- `git log --oneline -5`
- `git diff --stat HEAD~1 2>/dev/null`

Format the output as:

```
Branch: <branch> [sync status]

Status:
<short status or "(clean)">

Recent commits:
<last 5 commits>

Last commit changed:
<diff stat>
```
