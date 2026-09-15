Investigate an error - gather context, trace cause, suggest fix.

The error/context is: $ARGUMENTS

## Step 1: Parse the Error

If no error provided, ask for:
- Error message / stack trace / console output
- Or description of unexpected behavior

Extract:
- **Error type** (TypeError, SyntaxError, runtime, build, etc.)
- **File:line** if present
- **Function/component** involved
- **Key values** mentioned

## Step 2: Locate Ground Zero

Find the error source:
- If file:line given, read it directly
- If function name, search for definition
- If component name, search for export

## Step 3: Reproduce Context

Run in parallel:
- Recent changes: `git diff HEAD~5 --stat` and `git log --oneline -5`
- Current state: `git status --short`
- Type check: project type checker (tsc, cargo check, go vet, etc.)
- Tests: project test runner

## Step 4: Trace the Error

Based on error type, trace the data flow:

1. Where does the problematic value originate?
2. What transformations does it go through?
3. What assumptions are being violated?

Common patterns:
- **Async timing** - data not ready when accessed
- **Type mismatch** - expecting X, got Y
- **Missing null check** - optional value used as required
- **Stale closure** - capturing old value
- **Import cycle** - circular dependency
- **Environment** - missing env var or config

## Step 5: Present Findings

```
## Debug Report

### Error
<original error>

### Root Cause
<1-2 sentence explanation of WHY>

### Location
<file>:<line> - <function/component>

### The Problem
<code snippet>

### Why It Fails
<explanation>

### Suggested Fix
<corrected code>

### Prevention
- <how to prevent this class of bug>
```

## Step 6: Offer to Fix

Ask before applying. If yes, apply the fix and verify with type checker + tests.
