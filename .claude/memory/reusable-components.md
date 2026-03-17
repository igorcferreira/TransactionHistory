# Reusable Components

Components in `Sources/TransactionHistory/View/` that are shared across features.

## Current Components

### ShortTransactionView

**File:** `View/ShortTransactionView.swift`
**Purpose:** Compact row representation of a `CardTransaction` for use in lists.

**Layout:**
```
┌──────────────────────────────────────┐
│ Name (bold)              Amount      │
│ Merchant (secondary)     Time        │
└──────────────────────────────────────┘
```

**Usage:**
```swift
ShortTransactionView(transaction: transaction)
    .contentShape(Rectangle())
```

**Accessibility ID:** `"transaction_\(transaction.id)"`

---

### ToastView

**File:** `View/ToastView.swift`
**Purpose:** Temporary notification overlay that auto-dismisses after 3 seconds.

**Pattern:** View modifier

**Usage:**
```swift
someView.toast(message: $toastMessage)
```

**Behavior:**
- Appears at bottom with material background
- Rounded corners, padding
- Tap to dismiss
- Auto-dismisses after 3 seconds
- Binding-driven (set to `nil` to dismiss, set `String` to show)

---

### Iterate

**File:** `View/Iterate.swift`
**Purpose:** Helper for `ForEach` with enumerated sequences, maintaining stable IDs.

**Usage:**
```swift
Iterate(group.transactions.enumerated()) { transaction in
    ShortTransactionView(transaction: transaction)
}
```

**Why it exists:** Standard `ForEach` doesn't support `enumerated()` directly. `Iterate` wraps the enumeration and generates stable IDs as `"\(item.id)_\(index)"`.

---

### .includingMocks() Modifier

**File:** `Storage/DataStorage.swift` (extension)
**Purpose:** Attaches an in-memory `ModelContainer` with seeded sample data for previews.

**Usage:**
```swift
#Preview {
    TransactionListView()
        .includingMocks()
}
```

## Component Patterns for New Domains

When adding components for a new domain, follow these conventions:

| Component Type | Naming | Location |
|---------------|--------|----------|
| Row component | `Short[Domain]View` | `View/` |
| View modifier | `.behaviorName()` | `View/` |
| Domain-specific sub-view | `[Domain][Part]View` | `Feature/[Domain]/` |
| Shared utility view | Descriptive name | `View/` |

### When to Create a Reusable Component

- The same UI pattern is needed in **2+ features**.
- The component is **domain-agnostic** (doesn't depend on a specific model).
- It provides a **consistent behavior** (like toast notifications, empty states, loading indicators).

### When to Keep It Feature-Specific

- The component is tightly coupled to one domain's data model.
- It's only used in one screen.
- Making it reusable would require over-abstraction.
