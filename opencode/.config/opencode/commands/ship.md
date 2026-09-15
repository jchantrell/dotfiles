---
description: Run the pre-launch checklist — review, audit, test coverage, then go/no-go decision
---

Invoke the shipping-and-launch skill.

Run three specialist reviews in parallel against the current change, then merge into a single go/no-go decision with a rollback plan.

## Phase A — Parallel review

Run these three reviews concurrently using the Task tool:

1. **Code Review** — Five-axis review (correctness, readability, architecture, security, performance) on staged changes or recent commits.
2. **Security Audit** — Vulnerability and threat-model pass. Check OWASP Top 10, secrets handling, auth/authz, dependency CVEs.
3. **Test Coverage** — Analyze test coverage for the change. Identify gaps in happy path, edge cases, error paths, and concurrency scenarios.

## Phase B — Merge

Synthesize all three reports:

1. **Code Quality** — Aggregate Critical/Important findings. Resolve duplicates.
2. **Security** — Promote Critical/High findings to launch blockers.
3. **Performance** — Cross-check Core Web Vitals if applicable.
4. **Infrastructure** — Env vars, migrations, monitoring, feature flags.
5. **Documentation** — README, ADRs, changelog.

## Phase C — Decision

Produce a single output:

```markdown
## Ship Decision: GO | NO-GO

### Blockers (must fix before ship)
### Recommended fixes (should fix before ship)
### Acknowledged risks (shipping anyway)
### Rollback plan
```

Rules:
- The three Phase A reviews run in parallel — never sequentially.
- Rollback plan is mandatory before any GO decision.
- Any Critical finding defaults to NO-GO unless the user explicitly accepts the risk.
