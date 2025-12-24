# Development Guidelines

## Code Quality Standards

### Linting and Formatting
- Run linters for Rust and TypeScript before committing
- Apply formatters for Rust and TypeScript to maintain consistency

### Testing
- Write tests for Rust and TypeScript code
- Focus on testing behavior rather than implementation details
- Prefer integration tests that verify outcomes over unit tests that couple to internals

### Design Principles
- Follow SOLID principles to create maintainable, extensible code
- Apply clean code practices for readability and simplicity
- Use the adapter pattern to wrap third-party dependencies for easier testing

## Complexity Thresholds

### Cyclomatic Complexity
- Target complexity of 3 or less per function
- When complexity exceeds 3, refactor into smaller, focused functions

### File Size
- Keep files under 100 lines when possible
- Split larger files into modules with related functionality

### Function Length
- Keep functions under 30 lines
- Extract complex logic into well-named helper functions

### Function Parameters
- Limit functions to 3 parameters maximum
- Functions with 3 parameters should be rare
- When more parameters are needed, consider using a configuration object or struct

## Error Handling

- Use `expect()` with descriptive messages instead of `unwrap()`
- Make error cases explicit and informative

## Module Organization

- Each module should have a single, clear responsibility
- Group related functionality together
- Prioritize cohesion over rigid adherence to size limits

## Constraints

### Breaking Changes
- Never break existing tests without explicit approval
- Discuss test changes that affect behavior verification

### Style
- Do not use emojis in code, comments, or documentation

## Pragmatic Application

These guidelines exist to improve code quality, not to be followed dogmatically. Apply them where they add value:

- Keep cohesive code together even if it exceeds size thresholds
- Split files when separation improves clarity, not just to meet line counts
- Balance principles with practical considerations for the codebase
