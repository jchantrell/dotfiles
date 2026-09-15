List available package.json scripts.

Filter: $ARGUMENTS

1. Read `package.json` from the project root
2. Extract the `scripts` section
3. If a filter argument was provided, only show scripts whose name contains the filter
4. Format as an aligned table: script name → command
5. Sort alphabetically
