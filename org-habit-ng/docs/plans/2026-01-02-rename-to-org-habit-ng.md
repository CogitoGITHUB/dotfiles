# Rename org-habit-plus to org-habit-ng Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename the package from org-habit-plus to org-habit-ng across all files and symbols.

**Architecture:** Mechanical find-replace with file renames. No logic changes.

**Tech Stack:** Emacs Lisp, Elk task runner, beads issue tracker

---

### Task 1: Rename Main Elisp File

**Files:**
- Rename: `org-habit-plus.el` → `org-habit-ng.el`

**Step 1: Rename the file**

```bash
mv org-habit-plus.el org-habit-ng.el
```

**Step 2: Verify file exists**

```bash
ls -la org-habit-ng.el
```

Expected: File exists with correct name

---

### Task 2: Replace Prefixes in Main File

**Files:**
- Modify: `org-habit-ng.el`

**Step 1: Replace all org-habit-plus with org-habit-ng**

Use Edit tool with `replace_all: true` to change:
- `org-habit-plus` → `org-habit-ng`

**Step 2: Verify replacement count**

```bash
grep -c "org-habit-ng" org-habit-ng.el
```

Expected: ~437 occurrences (was org-habit-plus)

**Step 3: Verify no org-habit-plus remains**

```bash
grep -c "org-habit-plus" org-habit-ng.el
```

Expected: 0 occurrences

---

### Task 3: Rename Test File

**Files:**
- Rename: `test/org-habit-plus-test.el` → `test/org-habit-ng-test.el`

**Step 1: Rename the file**

```bash
mv test/org-habit-plus-test.el test/org-habit-ng-test.el
```

**Step 2: Verify file exists**

```bash
ls -la test/org-habit-ng-test.el
```

Expected: File exists with correct name

---

### Task 4: Replace Prefixes in Test File

**Files:**
- Modify: `test/org-habit-ng-test.el`

**Step 1: Replace all org-habit-plus with org-habit-ng**

Use Edit tool with `replace_all: true` to change:
- `org-habit-plus` → `org-habit-ng`

**Step 2: Verify replacement count**

```bash
grep -c "org-habit-ng" test/org-habit-ng-test.el
```

Expected: ~355 occurrences (was org-habit-plus)

**Step 3: Verify no org-habit-plus remains**

```bash
grep -c "org-habit-plus" test/org-habit-ng-test.el
```

Expected: 0 occurrences

---

### Task 5: Update Elkfile

**Files:**
- Modify: `Elkfile`

**Step 1: Update project name**

Change:
```elisp
:name "org-habit-plus"
```
To:
```elisp
:name "org-habit-ng"
```

**Step 2: Update load-file path**

Change:
```elisp
(load-file "org-habit-plus.el")
```
To:
```elisp
(load-file "org-habit-ng.el")
```

**Step 3: Update header comment**

Change:
```elisp
;;; Elkfile --- Elk project configuration for org-habit-plus
```
To:
```elisp
;;; Elkfile --- Elk project configuration for org-habit-ng
```

---

### Task 6: Update README.org

**Files:**
- Modify: `README.org`

**Step 1: Replace all org-habit-plus with org-habit-ng**

Use Edit tool with `replace_all: true` to change:
- `org-habit-plus` → `org-habit-ng`

**Step 2: Verify replacement**

```bash
grep -c "org-habit-ng" README.org
```

Expected: ~16 occurrences

**Step 3: Verify no org-habit-plus remains**

```bash
grep -c "org-habit-plus" README.org
```

Expected: 0 occurrences

---

### Task 7: Update Beads Prefix

**Step 1: Rename the beads prefix**

```bash
~/go/bin/bd rename-prefix ohng
```

Expected: Confirmation that prefix changed

**Step 2: Verify new prefix**

```bash
~/go/bin/bd list
```

Expected: Issue shows as `ohng-26e1` instead of `org-habit+.el-26e1`

---

### Task 8: Run Tests

**Step 1: Run the test suite**

```bash
vendor/elk/elk test
```

Expected: All tests pass

**Step 2: If tests fail, debug**

Check for any missed references to `org-habit-plus` that broke the rename.

---

### Task 9: Final Verification

**Step 1: Search for any remaining org-habit-plus references**

```bash
grep -r "org-habit-plus" --include="*.el" --include="*.org" --include="Elkfile" .
```

Expected: No results (except possibly in docs/plans/ historical files, which is OK)

**Step 2: Confirm key symbols exist**

```bash
grep "defun org-habit-ng-mode" org-habit-ng.el
grep "provide 'org-habit-ng" org-habit-ng.el
```

Expected: Both found
