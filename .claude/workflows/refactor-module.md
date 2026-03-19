# Workflow: Refactor Module

Safe, incremental refactoring process that preserves behavior.

## Inputs

- **Target** — which module/type/file to refactor
- **Motivation** — why refactor? (complexity, duplication, coupling, prep for new feature)
- **Constraints** — what must NOT change (public API, behavior, test expectations)

## Steps

### 1. Understand Current State

- [ ] Read the target code completely
- [ ] Identify all callers/dependents (grep for type/method usage)
- [ ] Read existing tests that cover this code
- [ ] Run all tests to confirm they pass before any changes

### 2. Define Target State

- [ ] What should the code look like after refactoring?
- [ ] Is the public API changing? If yes, identify all call sites to update
- [ ] Will this require new files or just restructuring existing ones?
- [ ] Check: is this refactoring necessary, or is the code fine as-is?

### 3. Plan the Steps

Break the refactoring into small, independently testable steps:

- [ ] Step A — (e.g., extract helper method)
- [ ] Step B — (e.g., move type to new file)
- [ ] Step C — (e.g., tighten access control)

Each step should leave all tests passing.

### 4. Execute Incrementally

For each step:

- [ ] Make the change
- [ ] Run iOS package tests to verify nothing broke
- [ ] If a test breaks, stop and assess — is it a valid behavior change or a bug?

### 5. Update Tests if Needed

- [ ] If API names changed, update test call sites
- [ ] If a helper was extracted, consider if it needs its own tests
- [ ] Do NOT add tests for trivial helpers (no speculative test coverage)
- [ ] Remove test code that's no longer relevant

### 6. Verify Definition of Done

- [ ] All existing tests pass (updated if API changed)
- [ ] No new SwiftLint violations
- [ ] `xcodebuild test` — iOS
- [ ] `swiftlint lint` — zero violations
- [ ] Code is measurably simpler (fewer lines, lower complexity, or better separation)

## Refactoring Decision Guide

| Signal | Recommended Action |
|--------|-------------------|
| Function > 30 lines | Extract focused helper methods |
| Type > 300 lines | Split into extensions or separate types |
| Same logic in 2+ places | Extract shared utility |
| Hard to test in isolation | Inject dependencies, extract pure functions |
| Mixed concerns | Separate into distinct types |
| Unused code | Remove entirely |

## What NOT to Do

- Don't refactor code you haven't read and understood
- Don't add abstractions for a single use case
- Don't introduce protocols "for testability" without a concrete need
- Don't change behavior — that's a feature or bug fix, not a refactor
- Don't refactor AND add features in the same pass
- Don't touch auto-generated code or Xcode project files
