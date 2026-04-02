# Rename org-habit-plus to org-habit-ng

## Summary

Rename the package from `org-habit-plus` to `org-habit-ng` across all elisp symbols, files, and configuration.

## Decisions

- **Directory name:** Keep as `org-habit+.el` (no change)
- **Beads prefix:** Change to `ohng-` (shorter, easier to type)
- **Historical docs:** Leave as-is (they document history accurately)

## Changes

### File Renames

| From | To |
|------|-----|
| `org-habit-plus.el` | `org-habit-ng.el` |
| `test/org-habit-plus-test.el` | `test/org-habit-ng-test.el` |

### Elisp Symbol Prefixes

Global find-replace in both `.el` files:
- `org-habit-plus` → `org-habit-ng`

This covers:
- Functions (e.g., `org-habit-plus-mode` → `org-habit-ng-mode`)
- Variables (e.g., `org-habit-plus--wizard-state` → `org-habit-ng--wizard-state`)
- Constants (e.g., `org-habit-plus--ordinal-alist` → `org-habit-ng--ordinal-alist`)
- Custom group
- Provide statement

### Configuration Files

**Elkfile:**
- `:name "org-habit-plus"` → `:name "org-habit-ng"`
- `(load-file "org-habit-plus.el")` → `(load-file "org-habit-ng.el")`

**Beads:**
- Run `bd rename-prefix ohng`
- Issue IDs change: `org-habit+.el-26e1` → `ohng-26e1`

### README.org

All `org-habit-plus` → `org-habit-ng`:
- Title
- Installation example
- Mode activation
- Command references

## Order of Operations

1. Rename `org-habit-plus.el` → `org-habit-ng.el`
2. Replace all `org-habit-plus` → `org-habit-ng` in `org-habit-ng.el`
3. Rename `test/org-habit-plus-test.el` → `test/org-habit-ng-test.el`
4. Replace all `org-habit-plus` → `org-habit-ng` in test file
5. Update Elkfile (name + load-file path)
6. Update README.org
7. Run `bd rename-prefix ohng`
8. Run tests to verify nothing broke

## Not Touched

- Directory name (stays `org-habit+.el`)
- Historical docs in `docs/plans/`
- Vendor directories
