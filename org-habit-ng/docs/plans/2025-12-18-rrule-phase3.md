# Phase 3: RRULE-Aware Consistency Graph - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace org-habit's fixed-interval graph with an RRULE-aware version that accurately shows due dates for complex recurrence patterns.

**Architecture:** Advice around `org-habit-build-graph` intercepts RRULE habits, generates accurate due dates using Phase 1 engine, and applies org-habit's face colors based on proximity to due dates. Standard habits delegate to original implementation.

**Tech Stack:** org-habit faces/glyphs, org-habit-plus Phase 1 RRULE engine, advice-add

---

## Task 1: Get Due Dates in Range

Generate all RRULE due dates within a day range for the graph window.

**Files:**
- Modify: `org-habit-plus.el` (add before line 1597, the `define-minor-mode`)
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-get-due-dates-in-range-weekly ()
  "Test getting due dates for weekly pattern."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Jan 1, 2024 is day 738886 (Monday)
         (start-day 738886)
         (end-day (+ start-day 21))  ; 3 weeks
         (dates (org-habit-plus--get-due-dates-in-range rule start-day end-day)))
    ;; Should get Jan 8, Jan 15, Jan 22
    (assert-equal 3 (length dates))
    (assert-equal (+ start-day 7) (nth 0 dates))
    (assert-equal (+ start-day 14) (nth 1 dates))
    (assert-equal (+ start-day 21) (nth 2 dates))))

(deftest test-get-due-dates-in-range-monthly ()
  "Test getting due dates for 2nd Saturday pattern."
  (let* ((rule '(:freq monthly :interval 1 :byday ((2 . 6))))
         ;; Dec 1, 2024 is day 739221
         (start-day 739221)
         (end-day (+ start-day 60))  ; ~2 months
         (dates (org-habit-plus--get-due-dates-in-range rule start-day end-day)))
    ;; Dec 14, 2024 (2nd Sat) = 739234, Jan 11, 2025 = 739262
    (assert-true (>= (length dates) 2))
    (assert-equal 739234 (nth 0 dates))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--get-due-dates-in-range"

**Step 3: Write minimal implementation**

```elisp
;;; Consistency Graph (Phase 3)

(defun org-habit-plus--get-due-dates-in-range (rule start-day end-day)
  "Get all RRULE due dates in range START-DAY to END-DAY (inclusive).
START-DAY and END-DAY are days since epoch (as used by org-habit).
RULE is a parsed RRULE plist.
Returns sorted list of day numbers."
  (let ((dates nil)
        ;; Start from well before the window to catch patterns
        (search-start (- start-day 400))  ; ~13 months back
        (current-dt (org-habit-plus--days-to-datetime search-start)))
    ;; Iterate forward until we pass end-day
    (while (< (org-habit-plus--datetime-to-days current-dt) end-day)
      (setq current-dt (org-habit-plus--rrule-next-occurrence rule current-dt))
      (when current-dt
        (let ((day (org-habit-plus--datetime-to-days current-dt)))
          (when (and (>= day start-day) (<= day end-day))
            (push day dates)))))
    (nreverse dates)))

(defun org-habit-plus--days-to-datetime (days)
  "Convert DAYS since epoch to datetime plist."
  (let ((time (days-to-time days)))
    (org-habit-plus--time-to-datetime time)))

(defun org-habit-plus--datetime-to-days (dt)
  "Convert datetime plist DT to days since epoch."
  (time-to-days (org-habit-plus--datetime-to-time dt)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 2: Get Nearest Due Date

Find the nearest due date to a given day.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-get-nearest-due-date-before ()
  "Test nearest due date when day is before all due dates."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-plus--get-nearest-due-date 95 due-dates)))
      (assert-equal -5 (car result))   ; 5 days before
      (assert-equal 100 (cdr result))))) ; nearest is 100

(deftest test-get-nearest-due-date-after ()
  "Test nearest due date when day is after a due date."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-plus--get-nearest-due-date 103 due-dates)))
      (assert-equal 3 (car result))    ; 3 days after
      (assert-equal 100 (cdr result))))) ; nearest is 100

(deftest test-get-nearest-due-date-between ()
  "Test nearest due date when day is between due dates."
  (let ((due-dates '(100 110 120)))
    ;; Day 106 is closer to 110 than 100
    (let ((result (org-habit-plus--get-nearest-due-date 106 due-dates)))
      (assert-equal -4 (car result))   ; 4 days before
      (assert-equal 110 (cdr result))))) ; nearest is 110

(deftest test-get-nearest-due-date-exact ()
  "Test nearest due date when day is exactly on due date."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-plus--get-nearest-due-date 110 due-dates)))
      (assert-equal 0 (car result))
      (assert-equal 110 (cdr result)))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--get-nearest-due-date"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--get-nearest-due-date (day due-dates)
  "Find the due date nearest to DAY from DUE-DATES.
Returns (DISTANCE . DUE-DATE) where DISTANCE is negative if DAY is
before the due date, positive if after, zero if exact match."
  (let ((best-distance most-positive-fixnum)
        (best-due nil))
    (dolist (due due-dates)
      (let ((dist (abs (- day due))))
        (when (< dist (abs best-distance))
          (setq best-distance (- day due))
          (setq best-due due))))
    (cons best-distance best-due)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 3: Get Face for Day

Determine the appropriate face based on distance to due date.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-get-graph-face-before-due ()
  "Test face for day before due date."
  (let ((face (org-habit-plus--get-graph-face -5 0 nil nil)))
    (assert-equal 'org-habit-clear-face (car face))))

(deftest test-get-graph-face-on-due ()
  "Test face for day on due date."
  (let ((face (org-habit-plus--get-graph-face 0 0 nil nil)))
    (assert-equal 'org-habit-ready-face (car face))))

(deftest test-get-graph-face-within-flexibility ()
  "Test face for day within flexibility window."
  (let ((face (org-habit-plus--get-graph-face 2 3 nil nil)))  ; 2 days after, 3 day flexibility
    (assert-equal 'org-habit-ready-face (car face))))

(deftest test-get-graph-face-at-deadline ()
  "Test face for day at deadline (end of flexibility)."
  (let ((face (org-habit-plus--get-graph-face 3 2 nil nil)))  ; 3 days after, 2 day flexibility
    (assert-equal 'org-habit-alert-face (car face))))

(deftest test-get-graph-face-overdue ()
  "Test face for overdue day."
  (let ((face (org-habit-plus--get-graph-face 5 0 nil nil)))
    (assert-equal 'org-habit-overdue-face (car face))))

(deftest test-get-graph-face-future ()
  "Test that future days get future face variant."
  (let ((face (org-habit-plus--get-graph-face -5 0 nil t)))  ; future-p = t
    (assert-equal 'org-habit-clear-future-face (cdr face))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--get-graph-face"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--get-graph-face (distance flexibility donep futurep)
  "Get face for a day based on DISTANCE from nearest due date.
DISTANCE is negative if before due, positive if after.
FLEXIBILITY is the grace period in days (from X-FLEXIBILITY).
DONEP is non-nil if the habit was completed on this day.
FUTUREP is non-nil if this day is in the future.
Returns (PAST-FACE . FUTURE-FACE) cons cell."
  (let ((flex (or flexibility 0)))
    (cond
     ;; Done and show-done-always-green
     ((and donep org-habit-show-done-always-green)
      '(org-habit-ready-face . org-habit-ready-future-face))
     ;; Before due date
     ((< distance 0)
      '(org-habit-clear-face . org-habit-clear-future-face))
     ;; On due date or within flexibility window
     ((<= distance flex)
      '(org-habit-ready-face . org-habit-ready-future-face))
     ;; At deadline (one day past flexibility)
     ((= distance (1+ flex))
      '(org-habit-alert-face . org-habit-alert-future-face))
     ;; Overdue
     (t
      '(org-habit-overdue-face . org-habit-overdue-future-face)))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 4: Get RRULE from Agenda Marker

Retrieve the RRULE from the source org entry via agenda marker.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-get-rrule-from-marker ()
  "Test retrieving RRULE via marker."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((marker (point-marker)))
      ;; Simulate agenda text property
      (with-temp-buffer
        (insert "  habit line")
        (put-text-property (point-min) (point-max) 'org-marker marker)
        (goto-char (point-min))
        (let ((rule (org-habit-plus--get-rrule-from-agenda-marker)))
          (assert-true rule)
          (assert-equal 'monthly (plist-get rule :freq)))))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--get-rrule-from-agenda-marker"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--get-rrule-from-agenda-marker ()
  "Get parsed RRULE from the org entry referenced by current agenda line.
Returns parsed RRULE plist or nil if no RECURRENCE property."
  (let ((marker (get-text-property (point) 'org-marker)))
    (when (and marker (marker-buffer marker))
      (with-current-buffer (marker-buffer marker)
        (save-excursion
          (goto-char marker)
          (let ((recurrence (org-entry-get nil org-habit-plus-recurrence-property)))
            (when (and recurrence (string-match-p "FREQ=" recurrence))
              (org-habit-plus--rrule-parse recurrence))))))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 5: Build Graph for RRULE Habit

The main graph building function for RRULE habits.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-build-graph-basic ()
  "Test building a basic RRULE graph."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Habit structure: (scheduled sr-days deadline dr-days done-dates sr-type)
         (habit (list 738886 7 nil nil '() ".+"))  ; Jan 1, 2024
         (starting (days-to-time 738880))  ; Dec 26, 2023
         (current (days-to-time 738890))   ; Jan 5, 2024
         (ending (days-to-time 738900))    ; Jan 15, 2024
         (graph (org-habit-plus--build-graph habit starting current ending rule)))
    ;; Graph should be a string
    (assert-true (stringp graph))
    ;; Graph length should match window size + 1
    (assert-equal 21 (length graph))))

(deftest test-build-graph-with-done-dates ()
  "Test that done dates show completed glyph."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Done on day 738893 (Jan 8)
         (habit (list 738886 7 nil nil '(738893) ".+"))
         (starting (days-to-time 738886))
         (current (days-to-time 738895))
         (ending (days-to-time 738900))
         (graph (org-habit-plus--build-graph habit starting current ending rule)))
    ;; Should have a completed glyph somewhere
    (assert-true (cl-find org-habit-completed-glyph graph))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--build-graph"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--build-graph (habit starting current ending rrule)
  "Build consistency graph for RRULE HABIT from STARTING to ENDING.
CURRENT is the current time for determining past/future.
RRULE is the parsed RRULE plist.
Returns a propertized string like `org-habit-build-graph'."
  (let* ((dominated-dates (org-habit-done-dates habit))
         (start-day (time-to-days starting))
         (now-day (time-to-days current))
         (end-day (time-to-days ending))
         (flexibility (or (plist-get rrule :flexibility) 0))
         (due-dates (org-habit-plus--get-due-dates-in-range rrule start-day end-day))
         (graph (make-string (1+ (- end-day start-day)) ?\s))
         (index 0))
    ;; Handle empty due-dates (fallback to simple interval)
    (when (null due-dates)
      (setq due-dates (list (org-habit-scheduled habit))))
    (while (<= start-day end-day)
      (let* ((in-past-p (< start-day now-day))
             (todayp (= start-day now-day))
             (futurep (> start-day now-day))
             (donep (member start-day dominated-dates))
             (nearest (org-habit-plus--get-nearest-due-date start-day due-dates))
             (distance (car nearest))
             (faces (org-habit-plus--get-graph-face distance flexibility donep futurep))
             (face (if (or in-past-p todayp) (car faces) (cdr faces))))
        ;; Set glyph
        (cond
         (donep (aset graph index org-habit-completed-glyph))
         (todayp (aset graph index org-habit-today-glyph)))
        ;; Set face
        (put-text-property index (1+ index) 'face face graph)
        ;; Set help-echo
        (put-text-property index (1+ index) 'help-echo
                           (format-time-string
                            (org-time-stamp-format)
                            (days-to-time start-day))
                           graph))
      (setq start-day (1+ start-day))
      (setq index (1+ index)))
    graph))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 6: Advice Around org-habit-build-graph

Set up the advice to intercept RRULE habits.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-graph-advice-delegates-for-standard-habit ()
  "Test that advice delegates to original for non-RRULE habits."
  ;; Create a temp buffer with a standard habit (no RECURRENCE)
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Standard habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1w>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((marker (point-marker)))
      (with-temp-buffer
        (insert "  habit line")
        (put-text-property (point-min) (point-max) 'org-marker marker)
        (goto-char (point-min))
        ;; Should return nil (no RRULE)
        (assert-nil (org-habit-plus--get-rrule-from-agenda-marker))))))

(deftest test-graph-advice-function-exists ()
  "Test that the advice function is defined."
  (assert-true (functionp 'org-habit-plus--around-build-graph)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "void-function: org-habit-plus--around-build-graph"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--around-build-graph (orig-fun habit starting current ending)
  "Advice to use RRULE-aware graph for habits with RECURRENCE property.
Falls back to ORIG-FUN for standard habits or on error."
  (let ((rrule (org-habit-plus--get-rrule-from-agenda-marker)))
    (if rrule
        (condition-case err
            (org-habit-plus--build-graph habit starting current ending rrule)
          (error
           (message "org-habit-plus graph error: %s, using fallback" (error-message-string err))
           (funcall orig-fun habit starting current ending)))
      (funcall orig-fun habit starting current ending))))

(defun org-habit-plus--enable-graph-advice ()
  "Enable advice on `org-habit-build-graph'."
  (advice-add 'org-habit-build-graph :around #'org-habit-plus--around-build-graph))

(defun org-habit-plus--disable-graph-advice ()
  "Disable advice on `org-habit-build-graph'."
  (advice-remove 'org-habit-build-graph #'org-habit-plus--around-build-graph))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 7: Integrate Graph Advice into Minor Mode

Update `org-habit-plus-mode` to enable/disable the graph advice.

**Files:**
- Modify: `org-habit-plus.el` (update `define-minor-mode`)
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-mode-enables-graph-advice ()
  "Test that enabling mode adds graph advice."
  (org-habit-plus-mode 1)
  (assert-true (advice-member-p #'org-habit-plus--around-build-graph 'org-habit-build-graph))
  (org-habit-plus-mode -1)
  (assert-nil (advice-member-p #'org-habit-plus--around-build-graph 'org-habit-build-graph)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL (advice not being added)

**Step 3: Update the minor mode definition**

Update `org-habit-plus-mode` to include graph advice:

```elisp
;;;###autoload
(define-minor-mode org-habit-plus-mode
  "Minor mode for complex recurrence patterns in org-habit."
  :global t
  :lighter " Habit+"
  (if org-habit-plus-mode
      (progn
        (org-habit-plus--enable-advice)
        (org-habit-plus--enable-parse-advice)
        (org-habit-plus--enable-graph-advice))
    (org-habit-plus--disable-advice)
    (org-habit-plus--disable-parse-advice)
    (org-habit-plus--disable-graph-advice)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 8: Integration Test - Full Graph Rendering

End-to-end test with a complete RRULE habit.

**Files:**
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write the integration test**

```elisp
(deftest test-full-graph-integration ()
  "Integration test for RRULE graph rendering."
  (org-habit-plus-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Monthly review\n")
        (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((marker (point-marker))
               (habit (list 738898 30 nil nil '() ".+"))  ; Jan 13, 2024
               (starting (days-to-time 738880))
               (current (days-to-time 738898))
               (ending (days-to-time 738920)))
          ;; Create mock agenda buffer context
          (with-temp-buffer
            (insert "  habit line")
            (put-text-property (point-min) (point-max) 'org-marker marker)
            (goto-char (point-min))
            ;; Call through the advice
            (let ((graph (org-habit-build-graph habit starting current ending)))
              (assert-true (stringp graph))
              (assert-true (> (length graph) 0))
              ;; Should have today glyph
              (assert-true (cl-find org-habit-today-glyph graph))))))
    (org-habit-plus-mode -1)))
```

**Step 2: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 3: Commit**

Skip (user preference)

---

## Summary

**8 tasks** implementing Phase 3 RRULE-aware consistency graph:

1. Get due dates in range - generate RRULE dates for graph window
2. Get nearest due date - find proximity for face coloring
3. Get face for day - determine color based on distance
4. Get RRULE from agenda marker - retrieve rule from source entry
5. Build graph for RRULE habit - main graph builder
6. Advice around org-habit-build-graph - intercept RRULE habits
7. Integrate into minor mode - enable/disable with mode
8. Integration test - full end-to-end verification

**Test command:** `vendor/elk/elk test`

**Entry point:** Enable `org-habit-plus-mode` and view habits in org-agenda
