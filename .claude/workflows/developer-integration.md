# Developer Workflow Integration

How to use Claude Code effectively throughout the development lifecycle of this project.

---

## Daily Development Patterns

### 1. Starting a New Feature

**Prompt pattern:**
```
Follow the create-feature workflow in .claude/workflows/create-feature.md.
Domain: Budget
Fields: name (String), limit (Double), currency (String), period (monthly/weekly)
Screens: list, detail, create
Intent: yes — "Set a budget"
Relationship: a Budget can have many CardTransactions
```

Claude will:
- Design the model following `CardTransaction` patterns
- Create the full layer stack (Model → Storage → Intent → ViewModel → View → Coordinator)
- Write tests for every layer
- Run the Definition of Done checks

**Key principle:** Give Claude the domain spec; let it follow the established patterns.

### 2. Building a UI Component

**Prompt pattern:**
```
Follow the build-ui-component workflow. Create a SpendingSummaryCard
that shows total spending grouped by merchant, displayed as a horizontal
bar chart. Data source: @Query on CardTransaction.
```

Claude will follow the ui-builder agent patterns and create the component with previews, accessibility, and tests.

### 3. Debugging an Issue

**Prompt pattern:**
```
Follow the debug-issue workflow. The transaction list shows duplicate
entries after creating a new transaction via Siri. It only happens
when the app is in the background.
```

Claude will trace the code path, identify the likely concurrency issue, write a failing test, and propose a minimal fix.

### 4. Reviewing a PR

**Prompt pattern:**
```
Follow the review-pr workflow for branch feature/budgets.
Scope: adds the Budget model and list screen.
```

Claude will review architecture compliance, code quality, concurrency, tests, and run all DoD checks.

### 5. Refactoring

**Prompt pattern:**
```
Follow the refactor-module workflow.
Target: DataStorage — extract a protocol so Budget and Transaction
storage can share the fetch pattern.
Constraint: all existing tests must pass unchanged.
```

---

## Agent-Based Workflows

Use agents for focused, specialized tasks by referencing them in your prompts:

| Task | How to Invoke |
|------|--------------|
| Design a feature's architecture | "Act as the ios-architect agent. Design the Category feature." |
| Review code for violations | "Act as the ios-reviewer agent. Review the changes in this PR." |
| Find crashes or threading bugs | "Act as the bug-hunter agent. The app freezes when syncing." |
| Improve code quality | "Act as the refactor-specialist agent. Simplify CurrencyMapper." |
| Build a SwiftUI component | "Act as the ui-builder agent. Create a merchant filter chip view." |

Agent definitions live in `.claude/agents/` and contain the rules, checklists, and patterns each agent follows.

---

## Efficient Prompt Patterns

### Be Specific About Scope

```
# Good — scoped and actionable
Add a `category` field to CardTransaction. It should be an optional
relationship to a new Category model. Update DataStorage, tests, and
the create form.

# Vague — Claude has to guess
Add categories to the app.
```

### Reference Project Patterns

```
# Good — points to existing pattern
Create BudgetListGroupView following the same @Query pattern
as TransactionListGroupView.

# Vague
Create a grouped list for budgets.
```

### Chain Tasks Naturally

```
1. "Design the Budget model and storage layer."
2. (review output) "Looks good. Now build the list and detail views."
3. (review output) "Add the coordinator and wire it into the app."
4. "Run all DoD checks."
```

---

## Pre-Commit Checklist

Before asking Claude to commit, always verify:

```
1. xcodebuild test (iOS)              # iOS package tests
2. swiftlint lint                     # Zero violations
3. (if app files changed) App tests   # iOS
```

You can ask Claude: **"Run the Definition of Done checks"** and it will execute all three.

---

## CI Integration

The GitHub Actions workflow (`.github/workflows/swift-tests.yml`) already runs:
- SwiftLint with GitHub annotations
- iOS Simulator tests (`xcodebuild test`)

This runs on every push/PR to `main` that touches source files.

### Keeping Local and CI Aligned

The same commands run locally and in CI. If Claude's DoD checks pass locally, CI will pass too.

---

## Knowledge System

### .claude/memory/ (Project Knowledge)

These files give Claude context about the project's patterns, architecture, and components. They're loaded when relevant and keep Claude consistent across conversations.

| File | When Claude Uses It |
|------|-------------------|
| `project-overview.md` | Starting any task — understands scope and tech stack |
| `architecture.md` | Designing features, reviewing architecture |
| `reusable-components.md` | Building UI, deciding what to extract |
| `networking.md` | When external data or APIs come up |
| `known-patterns.md` | Writing any code — follows established patterns |

### User Memory (Personal Preferences)

Stored in `~/.claude/projects/.../memory/`. Claude remembers your feedback:
- NavigationStack only in coordinators
- ModelContainer for DI, not ModelContext
- Single execution path through Intent

When you correct Claude, it saves the feedback for future conversations.

---

## Scaling the System

As the app grows, update these files:

| When You... | Update... |
|-------------|-----------|
| Add a new model | `index.md` (Data Models section), `memory/architecture.md` |
| Add a new feature | `index.md` (Feature Modules section) |
| Add a reusable component | `index.md` (Reusable Views), `memory/reusable-components.md` |
| Add networking | `memory/networking.md`, create `skills/networking-patterns.md` |
| Change architecture patterns | `skills/ios-architecture.md`, `memory/known-patterns.md` |
| Add a new convention | `skills/swift-coding-standards.md` |

Or simply tell Claude: **"Update the codebase index to reflect the new Budget feature"** and it will update the relevant files.
