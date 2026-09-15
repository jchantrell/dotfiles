Intelligent routing - analyze request and dispatch to the right approach.

Request: $ARGUMENTS

## Classify the Request

| Category | Signals | Route |
|----------|---------|-------|
| EXPLORATION | "what", "where", "how does", "find", "explain" | Explore agent |
| CODE_REVIEW | "review", "check", "audit", "feedback on" | /review-my-work or reviewer agent |
| REFACTOR | "rename", "migrate", "update all", "replace" | Agent with refactorer prompt |
| BUG_FIX | "fix", "broken", "error", "failing" | /debug |
| FEATURE | "add", "implement", "create", "build" | Direct or plan first |
| MULTI_TASK | multiple requests, "and also", list | Parallel agents |
| SESSION_MGMT | "done", "stopping", "standup" | /standup or /retro |

## Route

Based on classification:
1. **Invoke a command** if one matches
2. **Spawn an agent** for specialized work
3. **Handle directly** for simple requests

## Report

```markdown
## Triage Decision

**Request:** <original>
**Classification:** <CATEGORY>
**Confidence:** <high/medium/low>
**Routing:** <where>
**Reason:** <why>
```

For ambiguous requests, present options and ask which direction.
