Generate comprehensive tests for a file.

Target: $ARGUMENTS

## Step 1: Read the Source File

Read the full file contents to understand what to test.

## Step 2: Analyze the Code

Identify:
- **Exports** - What functions/classes are public?
- **Dependencies** - What needs mocking?
- **Edge cases** - Null, empty, boundary conditions
- **Error paths** - What can throw/fail?
- **Types** - What are the input/output shapes?

## Step 3: Check Existing Tests

Look for existing test files (*.test.*, *.spec.*, __tests__/).

## Step 4: Generate Tests

Cover:

### Unit Tests
- Happy path for each exported function
- Edge cases (empty input, null, undefined)
- Boundary conditions (min/max values)

### Error Cases
- Invalid input handling
- Exception throwing
- Error message accuracy

### Integration Points
- Mock external dependencies
- Test async behavior
- Verify side effects

## Step 5: Write Test File

Write to adjacent test file (same directory as source). Use the project's test framework.

## Step 6: Verify Tests Run

Run the test file and report results.

## Guidelines

- **AAA pattern** - Arrange, Act, Assert
- **One assertion per test** (when practical)
- **Descriptive names** - `should return empty array when input is null`
- **No test interdependence** - Each test isolated
- **Mock at boundaries** - External APIs, filesystem, network
- **Test behavior, not implementation**
