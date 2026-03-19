# Workflow: Review PR

Checklist-driven code review process for pull requests.

## Inputs

- **PR number or branch** — the changes to review
- **Scope** — what the PR is supposed to accomplish

## Steps

### 1. Understand the Intent

- [ ] Read the PR description / commit messages
- [ ] Identify what changed and why
- [ ] Confirm the scope matches the stated intent (no scope creep)

### 2. Review Architecture

- [ ] New files are in the correct directories per project structure
- [ ] NavigationStack only in Coordinator views
- [ ] Feature views use callbacks, not direct navigation
- [ ] ViewModels are `@Observable` (not `ObservableObject`)
- [ ] ModelContainer injected (not ModelContext) for DI
- [ ] Intent uses `callAsFunction(donate: true)` as single execution path
- [ ] No layer boundary violations (View doesn't import Storage directly, etc.)

### 3. Review Code Quality

- [ ] Functions are focused — single responsibility, low complexity
- [ ] Naming follows project conventions (see swift-coding-standards skill)
- [ ] Access control is appropriate (prefer most restrictive)
- [ ] No force unwraps without clear justification
- [ ] No dead code, commented-out blocks, or TODO placeholders
- [ ] Error types conform to `LocalizedError` with user-facing messages
- [ ] Comments explain intent where not obvious from code

### 4. Review Concurrency

- [ ] `@MainActor` on ViewModels that drive UI state
- [ ] `Sendable` conformance on types crossing actor boundaries
- [ ] `ModelContext` created locally, never passed across actors
- [ ] `async/await` used correctly — no blocking calls on main actor
- [ ] Closures don't accidentally capture `self` strongly

### 5. Review SwiftUI

- [ ] Views are lightweight — logic in ViewModel, not in body
- [ ] `@Query` used for reactive data (not manual fetch in onAppear)
- [ ] Accessibility identifiers present for testable elements
- [ ] `#Preview` blocks with `.includingMocks()` for every new view


### 6. Review Tests

- [ ] New code has corresponding tests
- [ ] Tests follow GIVEN-WHEN-THEN with `@Test` annotations
- [ ] Swift Testing framework used (not XCTest)
- [ ] In-memory containers — no shared state between tests
- [ ] Edge cases covered (empty state, boundary values, error paths)
- [ ] ViewModel validation tested (every `canSave` condition)

### 7. Run Verification

- [ ] `xcodebuild test` on iOS Simulator — iOS package tests pass
- [ ] `swiftlint lint` — zero violations
- [ ] If app-level files changed: run app unit tests on iOS

### 8. Classify Findings

| Level | Meaning | Action |
|-------|---------|--------|
| **Blocker** | Architecture violation, crash risk, data loss | Must fix |
| **Major** | Missing tests, concurrency issue, convention violation | Should fix |
| **Minor** | Naming nit, style preference, missing comment | Author's call |
| **Suggestion** | Alternative approach, future improvement | Optional |

## Output

A structured review with findings categorized by severity, specific file/line references, and suggested fixes.
