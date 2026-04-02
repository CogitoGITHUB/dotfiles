# Remove Repeater Requirement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Allow habits with RECURRENCE property to omit the org repeater from SCHEDULED timestamp.

**Architecture:** Modify `--around-parse-todo` to check for RECURRENCE first and build a synthetic habit structure instead of calling the original function (which errors without a repeater). Extract closed-dates logic into a reusable helper.

**Tech Stack:** Emacs Lisp, org-habit, e-unit testing framework

---

### Task 1: Add `--get-closed-dates` Helper

**Files:**
- Modify: `org-habit-ng.el`
- Test: `test/org-habit-ng-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-get-closed-dates ()
  "Test extracting DONE dates from logbook."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")
    (insert ":PROPERTIES:\n:STYLE: habit\n:END:\n")
    (insert ":LOGBOOK:\n")
    (insert "- State \"DONE\" from \"TODO\" [2024-01-14 Sun 10:00]\n")
    (insert "- State \"DONE\" from \"TODO\" [2024-01-10 Wed 09:00]\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((dates (org-habit-ng--get-closed-dates)))
      ;; Should have 2 dates
      (assert-equal 2 (length dates))
      ;; Dates should be days-since-epoch integers
      (assert-true (integerp (car dates))))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "org-habit-ng--get-closed-dates is void"

**Step 3: Write the implementation**

Add after `--approximate-interval` function (around line 261):

```elisp
(defun org-habit-ng--get-closed-dates ()
  "Extract past DONE dates from current heading's logbook.
Returns list of days-since-epoch, most recent first.
Must be called with point on or after the heading."
  (save-excursion
    (org-back-to-heading t)
    (let* ((end (org-entry-end-position))
           (maxdays (+ org-habit-preceding-days org-habit-following-days))
           (reversed org-log-states-order-reversed)
           (search (if reversed 're-search-forward 're-search-backward))
           (limit (if reversed end (point)))
           (count 0)
           (re (format
                "^[ \t]*-[ \t]+\\(?:State \"%s\".*%s%s\\)"
                (regexp-opt org-done-keywords)
                org-ts-regexp-inactive
                (let ((value (cdr (assq 'done org-log-note-headings))))
                  (if (not value) ""
                    (concat "\\|"
                            (org-replace-escapes
                             (regexp-quote value)
                             `(("%d" . ,org-ts-regexp-inactive)
                               ("%D" . ,org-ts-regexp)
                               ("%s" . "\"\\S-+\"")
                               ("%S" . "\"\\S-+\"")
                               ("%t" . ,org-ts-regexp-inactive)
                               ("%T" . ,org-ts-regexp)
                               ("%u" . ".*?")
                               ("%U" . ".*?"))))))))
           closed-dates)
      (unless reversed (goto-char end))
      (while (and (< count maxdays) (funcall search re limit t))
        (push (time-to-days
               (org-time-string-to-time
                (or (match-string-no-properties 1)
                    (match-string-no-properties 2))))
              closed-dates)
        (setq count (1+ count)))
      closed-dates)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

---

### Task 2: Add `--build-habit-struct` Function

**Files:**
- Modify: `org-habit-ng.el`
- Test: `test/org-habit-ng-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-build-habit-struct ()
  "Test building habit structure from RRULE."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=DAILY;INTERVAL=3\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let* ((rule (org-habit-ng--get-recurrence))
           (struct (org-habit-ng--build-habit-struct rule)))
      ;; Element 0: scheduled date (days since epoch)
      (assert-true (integerp (nth 0 struct)))
      ;; Element 1: interval in days
      (assert-equal 3 (nth 1 struct))
      ;; Element 2: deadline (nil)
      (assert-nil (nth 2 struct))
      ;; Element 3: deadline repeat (nil)
      (assert-nil (nth 3 struct))
      ;; Element 4: closed dates (list)
      (assert-true (listp (nth 4 struct)))
      ;; Element 5: repeater type (default ".+" for completion)
      (assert-equal ".+" (nth 5 struct)))))

(deftest test-build-habit-struct-scheduled-repeat ()
  "Test repeater type for X-REPEAT-FROM=scheduled."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=DAILY;X-REPEAT-FROM=scheduled\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let* ((rule (org-habit-ng--get-recurrence))
           (struct (org-habit-ng--build-habit-struct rule)))
      ;; Element 5: repeater type "++" for scheduled
      (assert-equal "++" (nth 5 struct)))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "org-habit-ng--build-habit-struct is void"

**Step 3: Write the implementation**

Add after `--get-closed-dates`:

```elisp
(defun org-habit-ng--build-habit-struct (rule)
  "Build habit structure from RRULE RULE.
Returns a list compatible with `org-habit-parse-todo':
  0: Scheduled date (days since epoch)
  1: Repeat interval in days
  2: Deadline (nil)
  3: Deadline repeat (nil)
  4: Past completion dates
  5: Repeater type string"
  (let* ((scheduled (org-get-scheduled-time (point)))
         (scheduled-days (and scheduled (time-to-days scheduled)))
         (interval (org-habit-ng--approximate-interval rule))
         (repeat-from (or (plist-get rule :repeat-from) 'completion))
         (repeater-type (if (eq repeat-from 'completion) ".+" "++"))
         (closed-dates (org-habit-ng--get-closed-dates)))
    (unless scheduled-days
      (error "Habit '%s' has no scheduled date"
             (org-no-properties (org-get-heading t t t t))))
    (list scheduled-days
          interval
          nil
          nil
          closed-dates
          repeater-type)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

---

### Task 3: Modify `--around-parse-todo` to Check RECURRENCE First

**Files:**
- Modify: `org-habit-ng.el`
- Test: `test/org-habit-ng-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-parse-todo-without-repeater ()
  "Test that habits with RECURRENCE work without org repeater."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")  ; No .+1d repeater!
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=DAILY;INTERVAL=2\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-ng-mode 1)
    (unwind-protect
        (let ((habit (org-habit-parse-todo)))
          ;; Should succeed (not throw error about missing repeater)
          (assert-true habit)
          ;; Interval should be 2 days
          (assert-equal 2 (nth 1 habit))
          ;; Repeater type should be ".+"
          (assert-equal ".+" (nth 5 habit)))
      (org-habit-ng-mode -1))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "Habit ... has no scheduled repeat period"

**Step 3: Modify the implementation**

Replace the existing `--around-parse-todo` function:

```elisp
(defun org-habit-ng--around-parse-todo (orig-fun &optional pom)
  "Advice around `org-habit-parse-todo' to handle RRULE recurrence.
If RECURRENCE property exists, builds habit structure directly
without requiring an org repeater. Otherwise, calls original function
and adjusts interval based on RRULE."
  (save-excursion
    (when pom (goto-char pom))
    (let ((recurrence (org-habit-ng--get-recurrence)))
      (if recurrence
          ;; RECURRENCE exists: build synthetic habit struct
          (org-habit-ng--build-habit-struct recurrence)
        ;; No RECURRENCE: use original org-habit behavior
        (funcall orig-fun pom)))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

---

### Task 4: Test Integration with Graph and Done Handling

**Files:**
- Test: `test/org-habit-ng-test.el`

**Step 1: Write integration tests**

```elisp
(deftest test-integration-habit-without-repeater-graph ()
  "Test that graph works for habits without org repeater."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-ng-mode 1)
    (unwind-protect
        (let ((habit (org-habit-parse-todo)))
          ;; Graph should build without error
          (assert-true habit)
          ;; Should have correct interval (~2-3 days for MWF)
          (assert-true (<= 2 (nth 1 habit) 3)))
      (org-habit-ng-mode -1))))

(deftest test-integration-habit-without-repeater-done ()
  "Test marking DONE works for habits without org repeater."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-15 Mon>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=DAILY;INTERVAL=3\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-ng-mode 1)
    (unwind-protect
        (progn
          ;; Mark as DONE
          (org-todo "DONE")
          ;; Should have been rescheduled (not errored)
          (let ((new-scheduled (org-entry-get nil "SCHEDULED")))
            (assert-true new-scheduled)
            ;; Should still not have a repeater (we don't add one)
            (assert-nil (string-match "\\.\\+\\|\\+\\+" new-scheduled))))
      (org-habit-ng-mode -1))))
```

**Step 2: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

### Task 5: Update README Examples

**Files:**
- Modify: `README.org`

**Step 1: Update examples to remove repeaters**

Find all habit examples with `.+1m`, `.+1d`, etc. and remove the repeater portion.

Change:
```org
SCHEDULED: <2024-01-13 Sat .+1m>
```

To:
```org
SCHEDULED: <2024-01-13 Sat>
```

**Step 2: Add note about backwards compatibility**

After the installation section, add:

```org
Note: Unlike standard org-habit, org-habit-ng does not require a repeater
(e.g., =.+1d=) in the SCHEDULED timestamp. The =RECURRENCE= property
controls all scheduling.
```

**Step 3: Run tests to ensure nothing broke**

Run: `vendor/elk/elk test`
Expected: All tests pass

---

### Task 6: Final Verification

**Step 1: Run full test suite**

Run: `vendor/elk/elk test`
Expected: All tests pass

**Step 2: Verify no stray repeater requirements**

```bash
grep -n "repeat.*period\|repeater" org-habit-ng.el
```

Expected: Only comments/docstrings, no error-throwing code requiring repeaters

**Step 3: Close the bead**

```bash
~/go/bin/bd close ohng-26e1
```
