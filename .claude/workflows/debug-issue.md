# Workflow: Debug Issue

Structured process for diagnosing and fixing bugs.

## Inputs

- **Symptom** — what the user sees (crash, incorrect data, visual glitch, freeze)
- **Reproduction steps** — how to trigger the issue (if known)
- **Context** — which screen, which action, how often

## Steps

### 1. Understand the Symptom

- [ ] Clarify what "broken" means — crash? wrong data? wrong UI? performance?
- [ ] Identify the affected screen/feature
- [ ] Determine if it's consistent or intermittent


### 2. Locate the Code Path

- [ ] Trace the user action to the relevant View
- [ ] Follow the callback chain: View → Coordinator → ViewModel → Intent/Storage → Model
- [ ] Identify which layer the bug likely lives in:
  - **View layer** — visual issues, layout, missing updates
  - **ViewModel layer** — wrong state, validation failure, stale data
  - **Storage layer** — fetch returning wrong results, missing data
  - **Intent layer** — creation failure, parse error
  - **Model layer** — wrong defaults, broken computed properties
  - **Concurrency** — threading violation, race condition

### 3. Read the Relevant Code

- [ ] Read the full code path end-to-end (don't guess from file names)
- [ ] Check for common issues:
  - `ModelContext` used across actor boundaries
  - `@Query` predicate not updating when state changes
  - Closure capturing `self` strongly in `@Observable` class
  - `@State` initialized with computed value (only evaluates once)
  - Sheet/navigation binding not reset after dismissal
  - Missing `@MainActor` on ViewModel method called from View

### 4. Write a Failing Test

- [ ] Create a test that reproduces the bug (fails before fix)
- [ ] Follow GIVEN-WHEN-THEN with Swift Testing (`@Test`)
- [ ] Use in-memory container for data-related bugs

### 5. Implement the Fix

- [ ] Make the minimal change that fixes the root cause
- [ ] Don't refactor surrounding code — fix only the bug
- [ ] Verify the failing test now passes

### 6. Check for Same Pattern Elsewhere

- [ ] Search the codebase for the same bug pattern
- [ ] Fix other instances if found
- [ ] Consider if a systemic change prevents recurrence

### 7. Verify Definition of Done

- [ ] The new test passes
- [ ] All existing tests still pass
- [ ] `xcodebuild test` — iOS
- [ ] `swiftlint lint` — zero violations

## Common Bug Categories

| Category | Likely Layer | First Thing to Check |
|----------|-------------|---------------------|
| Crash on tap | Coordinator/View | Navigation binding, force unwrap |
| Data not showing | Storage/Query | FetchDescriptor predicate, @Query init |
| Stale UI after save | View/Query | @Query not re-evaluating, missing modelContext |
| Crash on background | Concurrency | ModelContext crossing actors |
| Form won't save | ViewModel | canSave validation logic |
| Search not filtering | ViewModel/Query | Predicate rebuild, empty string handling |
