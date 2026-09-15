Run TypeScript type check and group errors by file.

Target: $ARGUMENTS

1. Run `pnpm exec tsc --noEmit` (or on the specific file if provided)
2. Parse the output for `error TS` lines
3. Group errors by file
4. For each file, show: file path, then indented list of errors with line number and error code
5. Summary: total errors, total files affected
6. If no errors: report clean
