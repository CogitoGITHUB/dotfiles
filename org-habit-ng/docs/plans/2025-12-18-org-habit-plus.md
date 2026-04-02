# org-habit-plus Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extend org-habit to support complex recurrence patterns like "second Saturday of month" while preserving habit tracking and consistency graphs.

**Architecture:** Store recurrence rules in a `:RECURRENCE:` property, advise `org-auto-repeat-maybe` to compute next occurrence using `calendar-nth-named-day`, and advise `org-habit-parse-todo` to calculate approximate intervals for graph display. The SCHEDULED timestamp always holds the *next* occurrence date.

**Tech Stack:** Emacs Lisp, org-mode, calendar.el, Elk (task runner), e-unit (testing)

---

## Task 1: Project Skeleton and Package Header

**Files:**
- Create: `org-habit-plus.el`
- Create: `test/org-habit-plus-test.el`
- Create: `Elkfile`

**Step 1: Create main package file with proper headers**

```elisp
;;; org-habit-plus.el --- Complex recurrence patterns for org-habit -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Your Name

;; Author: Your Name
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (org "9.6"))
;; Keywords: calendar, org, habits
;; URL: https://github.com/yourusername/org-habit-plus

;; This file is not part of GNU Emacs.

;;; Commentary:

;; org-habit-plus extends org-habit to support complex recurrence patterns
;; that cannot be expressed with standard org repeaters.  Examples:
;;
;;   - "second saturday of month"
;;   - "last friday of month"
;;   - "first weekday of month"
;;
;; Usage:
;;   (require 'org-habit-plus)
;;   (org-habit-plus-mode 1)
;;
;; Then add a :RECURRENCE: property to your habit:
;;
;;   * TODO Exercise
;;   SCHEDULED: <2024-01-13 Sat>
;;   :PROPERTIES:
;;   :STYLE: habit
;;   :RECURRENCE: second saturday of month
;;   :END:

;;; Code:

(require 'org)
(require 'org-habit)
(require 'calendar)

(defgroup org-habit-plus nil
  "Complex recurrence patterns for org-habit."
  :group 'org-habit
  :prefix "org-habit-plus-")

(provide 'org-habit-plus)
;;; org-habit-plus.el ends here
```

Write this to `org-habit-plus.el`.

**Step 2: Create Elkfile for project management**

```elisp
;;; Elkfile --- Elk project configuration for org-habit-plus -*- lexical-binding: t; -*-

(elk-project
 :name "org-habit-plus"
 :version "0.1.0"
 :source-dirs '(".")
 :test-dirs '("test/"))

(elk-set 'test-framework 'e-unit)
(elk-set 'clean-patterns '("*.elc" "*.eln"))

;;; Elkfile ends here
```

Write this to `Elkfile`.

**Step 3: Create test file skeleton**

```elisp
;;; org-habit-plus-test.el --- Tests for org-habit-plus -*- lexical-binding: t; -*-

;;; Commentary:

;; e-unit tests for org-habit-plus

;;; Code:

(require 'e-unit)
(require 'org-habit-plus)

(e-unit-initialize)

(provide 'org-habit-plus-test)
;;; org-habit-plus-test.el ends here
```

Write this to `test/org-habit-plus-test.el`.

**Step 4: Run tests to verify setup**

Run: `elk test`
Expected: 0 tests run, no errors

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 2: Ordinal and Weekday Parsing Constants

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write the failing test for ordinal parsing**

Add to `test/org-habit-plus-test.el` before `(provide ...)`:

```elisp
(deftest test-ordinal-to-number ()
  "Test ordinal string to number conversion."
  (assert-equal 1 (org-habit-plus--ordinal-to-number "first"))
  (assert-equal 1 (org-habit-plus--ordinal-to-number "1st"))
  (assert-equal 2 (org-habit-plus--ordinal-to-number "second"))
  (assert-equal 2 (org-habit-plus--ordinal-to-number "2nd"))
  (assert-equal 3 (org-habit-plus--ordinal-to-number "third"))
  (assert-equal 3 (org-habit-plus--ordinal-to-number "3rd"))
  (assert-equal 4 (org-habit-plus--ordinal-to-number "fourth"))
  (assert-equal 4 (org-habit-plus--ordinal-to-number "4th"))
  (assert-equal 5 (org-habit-plus--ordinal-to-number "fifth"))
  (assert-equal 5 (org-habit-plus--ordinal-to-number "5th"))
  (assert-equal -1 (org-habit-plus--ordinal-to-number "last")))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--ordinal-to-number"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el` before `(provide ...)`:

```elisp
(defconst org-habit-plus--ordinal-alist
  '(("first" . 1) ("1st" . 1)
    ("second" . 2) ("2nd" . 2)
    ("third" . 3) ("3rd" . 3)
    ("fourth" . 4) ("4th" . 4)
    ("fifth" . 5) ("5th" . 5)
    ("last" . -1) ("second-to-last" . -2))
  "Alist mapping ordinal strings to numbers.
Negative numbers count from the end.")

(defun org-habit-plus--ordinal-to-number (ordinal)
  "Convert ORDINAL string to a number.
Returns negative for \"last\" (-1), \"second-to-last\" (-2), etc."
  (cdr (assoc (downcase ordinal) org-habit-plus--ordinal-alist)))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: PASS

**Step 5: Write failing test for weekday parsing**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-weekday-to-number ()
  "Test weekday string to number conversion."
  (assert-equal 0 (org-habit-plus--weekday-to-number "sunday"))
  (assert-equal 0 (org-habit-plus--weekday-to-number "sun"))
  (assert-equal 1 (org-habit-plus--weekday-to-number "monday"))
  (assert-equal 1 (org-habit-plus--weekday-to-number "mon"))
  (assert-equal 2 (org-habit-plus--weekday-to-number "tuesday"))
  (assert-equal 3 (org-habit-plus--weekday-to-number "wednesday"))
  (assert-equal 4 (org-habit-plus--weekday-to-number "thursday"))
  (assert-equal 5 (org-habit-plus--weekday-to-number "friday"))
  (assert-equal 6 (org-habit-plus--weekday-to-number "saturday"))
  (assert-equal 6 (org-habit-plus--weekday-to-number "sat")))
```

**Step 6: Run test to verify it fails**

Run: `elk test`
Expected: 1 passed, 1 FAIL

**Step 7: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defconst org-habit-plus--weekday-alist
  '(("sunday" . 0) ("sun" . 0) ("su" . 0)
    ("monday" . 1) ("mon" . 1) ("mo" . 1)
    ("tuesday" . 2) ("tue" . 2) ("tu" . 2)
    ("wednesday" . 3) ("wed" . 3) ("we" . 3)
    ("thursday" . 4) ("thu" . 4) ("th" . 4)
    ("friday" . 5) ("fri" . 5) ("fr" . 5)
    ("saturday" . 6) ("sat" . 6) ("sa" . 6))
  "Alist mapping weekday strings to numbers (0=Sunday).")

(defun org-habit-plus--weekday-to-number (weekday)
  "Convert WEEKDAY string to a number (0=Sunday, 6=Saturday)."
  (cdr (assoc (downcase weekday) org-habit-plus--weekday-alist)))
```

**Step 8: Run test to verify it passes**

Run: `elk test`
Expected: 2 passed

**Step 9: DO NOT commit (user requested no git changes)**

---

## Task 3: Recurrence Rule Parsing

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for parsing "second saturday of month"**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-parse-recurrence-nth-weekday ()
  "Test parsing nth weekday of month patterns."
  (let ((result (org-habit-plus--parse-recurrence "second saturday of month")))
    (assert-equal 'nth-weekday (plist-get result :type))
    (assert-equal 2 (plist-get result :n))
    (assert-equal 6 (plist-get result :weekday))
    (assert-equal t (plist-get result :month)))
  (let ((result (org-habit-plus--parse-recurrence "last friday of month")))
    (assert-equal 'nth-weekday (plist-get result :type))
    (assert-equal -1 (plist-get result :n))
    (assert-equal 5 (plist-get result :weekday)))
  (let ((result (org-habit-plus--parse-recurrence "1st monday of month")))
    (assert-equal 'nth-weekday (plist-get result :type))
    (assert-equal 1 (plist-get result :n))
    (assert-equal 1 (plist-get result :weekday))))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--parse-recurrence"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defconst org-habit-plus--nth-weekday-regexp
  (concat "\\<\\("
          (mapconcat #'car org-habit-plus--ordinal-alist "\\|")
          "\\)\\s-+\\("
          (mapconcat #'car org-habit-plus--weekday-alist "\\|")
          "\\)\\s-+of\\s-+month\\>")
  "Regexp matching 'Nth weekday of month' patterns.")

(defun org-habit-plus--parse-recurrence (string)
  "Parse recurrence STRING into a plist.
Returns a plist with :type and type-specific keys.

Supported patterns:
  - \"second saturday of month\" -> (:type nth-weekday :n 2 :weekday 6 :month t)
  - \"last friday of month\"     -> (:type nth-weekday :n -1 :weekday 5 :month t)"
  (let ((str (downcase (string-trim string))))
    (cond
     ;; Nth weekday of month: "second saturday of month"
     ((string-match org-habit-plus--nth-weekday-regexp str)
      (let ((ordinal (match-string 1 str))
            (weekday (match-string 2 str)))
        (list :type 'nth-weekday
              :n (org-habit-plus--ordinal-to-number ordinal)
              :weekday (org-habit-plus--weekday-to-number weekday)
              :month t)))
     (t
      (error "Cannot parse recurrence pattern: %s" string)))))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 3 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 4: Compute Next Occurrence for Nth Weekday

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for next occurrence calculation**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-next-occurrence-nth-weekday ()
  "Test computing next occurrence for nth weekday patterns."
  ;; Second Saturday of month - if we're past it, get next month's
  (let* ((rule (org-habit-plus--parse-recurrence "second saturday of month"))
         ;; From Jan 14, 2024 (after 2nd Sat Jan 13), next is Feb 10, 2024
         (next (org-habit-plus--next-occurrence rule '(1 14 2024))))
    (assert-equal '(2 10 2024) next))
  ;; Last Friday of January 2024 is Jan 26
  (let* ((rule (org-habit-plus--parse-recurrence "last friday of month"))
         ;; From Jan 1, 2024, next last Friday is Jan 26, 2024
         (next (org-habit-plus--next-occurrence rule '(1 1 2024))))
    (assert-equal '(1 26 2024) next))
  ;; From Jan 27, 2024 (after last Friday), next is Feb 23, 2024
  (let* ((rule (org-habit-plus--parse-recurrence "last friday of month"))
         (next (org-habit-plus--next-occurrence rule '(1 27 2024))))
    (assert-equal '(2 23 2024) next)))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--next-occurrence"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--nth-weekday-in-month (n weekday month year)
  "Return Gregorian date of Nth WEEKDAY in MONTH YEAR.
N can be negative (-1 = last, -2 = second-to-last).
WEEKDAY is 0-6 (Sunday-Saturday).
Returns (MONTH DAY YEAR)."
  (calendar-nth-named-day n weekday month year))

(defun org-habit-plus--next-occurrence (rule from-date)
  "Compute next occurrence of RULE strictly after FROM-DATE.
FROM-DATE is (MONTH DAY YEAR).
Returns (MONTH DAY YEAR)."
  (let ((type (plist-get rule :type)))
    (pcase type
      ('nth-weekday
       (org-habit-plus--next-nth-weekday rule from-date))
      (_
       (error "Unknown recurrence type: %s" type)))))

(defun org-habit-plus--next-nth-weekday (rule from-date)
  "Compute next nth-weekday occurrence after FROM-DATE.
RULE is a plist with :n and :weekday.
FROM-DATE is (MONTH DAY YEAR)."
  (let* ((n (plist-get rule :n))
         (weekday (plist-get rule :weekday))
         (from-month (nth 0 from-date))
         (from-year (nth 2 from-date))
         (from-absolute (calendar-absolute-from-gregorian from-date))
         ;; Try current month first
         (candidate (org-habit-plus--nth-weekday-in-month
                     n weekday from-month from-year))
         (candidate-absolute (calendar-absolute-from-gregorian candidate)))
    ;; If candidate is not strictly after from-date, try next month
    (if (> candidate-absolute from-absolute)
        candidate
      ;; Move to next month
      (let ((next-month (1+ from-month))
            (next-year from-year))
        (when (> next-month 12)
          (setq next-month 1)
          (setq next-year (1+ next-year)))
        (org-habit-plus--nth-weekday-in-month n weekday next-month next-year)))))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 4 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 5: Get Recurrence Property from Org Entry

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for getting recurrence from org entry**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-get-recurrence ()
  "Test getting recurrence property from org entry."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: second saturday of month\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((recurrence (org-habit-plus--get-recurrence)))
      (assert-true recurrence)
      (assert-equal 'nth-weekday (plist-get recurrence :type))
      (assert-equal 2 (plist-get recurrence :n))
      (assert-equal 6 (plist-get recurrence :weekday)))))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--get-recurrence"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defconst org-habit-plus-recurrence-property "RECURRENCE"
  "Property name for storing complex recurrence rules.")

(defun org-habit-plus--get-recurrence (&optional pom)
  "Get parsed recurrence rule from entry at POM.
Returns nil if no RECURRENCE property exists."
  (let ((recurrence-string (org-entry-get pom org-habit-plus-recurrence-property)))
    (when recurrence-string
      (org-habit-plus--parse-recurrence recurrence-string))))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 5 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 6: Convert Between Date Formats

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for date format conversion**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-date-conversions ()
  "Test date format conversions."
  ;; Gregorian to org timestamp string
  (assert-match "2024-01-13"
                (org-habit-plus--gregorian-to-org-ts '(1 13 2024)))
  ;; Org timestamp to Gregorian
  (assert-equal '(1 13 2024)
                (org-habit-plus--org-ts-to-gregorian "<2024-01-13 Sat>"))
  (assert-equal '(2 10 2024)
                (org-habit-plus--org-ts-to-gregorian "<2024-02-10 Sat .+1m>")))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--gregorian-to-org-ts"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--gregorian-to-org-ts (date)
  "Convert Gregorian DATE (MONTH DAY YEAR) to org timestamp string."
  (let* ((month (nth 0 date))
         (day (nth 1 date))
         (year (nth 2 date))
         (time (encode-time 0 0 0 day month year))
         (dow (format-time-string "%a" time)))
    (format "<%04d-%02d-%02d %s>" year month day dow)))

(defun org-habit-plus--org-ts-to-gregorian (ts-string)
  "Convert org timestamp TS-STRING to Gregorian date (MONTH DAY YEAR)."
  (let ((time (org-time-string-to-time ts-string)))
    (let ((decoded (decode-time time)))
      (list (nth 4 decoded)   ; month
            (nth 3 decoded)   ; day
            (nth 5 decoded))))) ; year
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 6 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 7: Core Repeat Handler

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for repeat handler**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-handle-repeat ()
  "Test that handle-repeat updates SCHEDULED to next occurrence."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: second saturday of month\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Simulate completing the habit
    (org-habit-plus--handle-repeat)
    ;; Should now be scheduled for Feb 10, 2024 (2nd Sat of Feb)
    (let ((scheduled (org-entry-get nil "SCHEDULED")))
      (assert-match "2024-02-10" scheduled))))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--handle-repeat"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--handle-repeat ()
  "Handle repeat for an org-habit-plus entry.
Computes the next occurrence based on RECURRENCE property
and updates SCHEDULED timestamp accordingly."
  (let ((recurrence (org-habit-plus--get-recurrence)))
    (when recurrence
      (let* ((scheduled-ts (org-entry-get nil "SCHEDULED"))
             (current-date (org-habit-plus--org-ts-to-gregorian scheduled-ts))
             (next-date (org-habit-plus--next-occurrence recurrence current-date))
             (next-ts (org-habit-plus--gregorian-to-org-ts next-date)))
        (org-schedule nil next-ts)))))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 7 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 8: Advice for org-auto-repeat-maybe

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for advice integration**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-advice-integration ()
  "Test that advice intercepts org-auto-repeat-maybe."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: second saturday of month\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Enable org-habit-plus-mode
    (org-habit-plus-mode 1)
    ;; Simulate the advice being called
    (org-habit-plus--after-auto-repeat "DONE")
    ;; Should be scheduled for 2nd Sat of Feb
    (let ((scheduled (org-entry-get nil "SCHEDULED")))
      (assert-match "2024-02-10" scheduled))
    ;; Clean up
    (org-habit-plus-mode -1)))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--after-auto-repeat"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--after-auto-repeat (_done-word)
  "Advice to run after `org-auto-repeat-maybe'.
Overrides the timestamp if entry has a RECURRENCE property."
  (when (and (org-is-habit-p)
             (org-habit-plus--get-recurrence))
    (org-habit-plus--handle-repeat)))

(defun org-habit-plus--enable-advice ()
  "Enable advice on `org-auto-repeat-maybe'."
  (advice-add 'org-auto-repeat-maybe :after #'org-habit-plus--after-auto-repeat))

(defun org-habit-plus--disable-advice ()
  "Disable advice on `org-auto-repeat-maybe'."
  (advice-remove 'org-auto-repeat-maybe #'org-habit-plus--after-auto-repeat))

;;;###autoload
(define-minor-mode org-habit-plus-mode
  "Minor mode for complex recurrence patterns in org-habit."
  :global t
  :lighter " Habit+"
  (if org-habit-plus-mode
      (org-habit-plus--enable-advice)
    (org-habit-plus--disable-advice)))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 8 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 9: Approximate Interval for Graph Display

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for approximate interval calculation**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-approximate-interval ()
  "Test approximate interval calculation for graph display."
  ;; Nth weekday of month is roughly every 28-31 days
  (let ((rule (org-habit-plus--parse-recurrence "second saturday of month")))
    (let ((interval (org-habit-plus--approximate-interval rule)))
      ;; Should be around 30 days (monthly)
      (assert-true (>= interval 28))
      (assert-true (<= interval 31))))
  ;; "last friday" is also monthly
  (let ((rule (org-habit-plus--parse-recurrence "last friday of month")))
    (let ((interval (org-habit-plus--approximate-interval rule)))
      (assert-true (>= interval 28))
      (assert-true (<= interval 31)))))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL with "void-function org-habit-plus--approximate-interval"

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--approximate-interval (rule)
  "Calculate approximate interval in days for RULE.
Used for org-habit graph display."
  (let ((type (plist-get rule :type)))
    (pcase type
      ('nth-weekday
       ;; Monthly patterns average ~30 days
       30)
      (_
       ;; Default to weekly if unknown
       7))))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 9 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 10: Advice for org-habit-parse-todo

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for parse-todo advice**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-parse-todo-advice ()
  "Test that parse-todo returns correct interval for complex recurrence."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1d>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: second saturday of month\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-plus-mode 1)
    ;; Parse the habit
    (let ((habit-data (org-habit-parse-todo)))
      ;; Element 1 is the repeat interval in days
      ;; Should be ~30 (monthly) instead of 1 (from .+1d)
      (assert-true (>= (nth 1 habit-data) 28))
      (assert-true (<= (nth 1 habit-data) 31)))
    (org-habit-plus-mode -1)))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL (interval will be 1, not ~30)

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defun org-habit-plus--around-parse-todo (orig-fun &optional pom)
  "Advice around `org-habit-parse-todo' to handle complex recurrence.
Replaces the interval with approximate interval if RECURRENCE is set."
  (let ((result (funcall orig-fun pom)))
    (when result
      (save-excursion
        (when pom (goto-char pom))
        (let ((recurrence (org-habit-plus--get-recurrence)))
          (when recurrence
            ;; Replace element 1 (sr-days) with approximate interval
            (setf (nth 1 result)
                  (org-habit-plus--approximate-interval recurrence))))))
    result))

(defun org-habit-plus--enable-parse-advice ()
  "Enable advice on `org-habit-parse-todo'."
  (advice-add 'org-habit-parse-todo :around #'org-habit-plus--around-parse-todo))

(defun org-habit-plus--disable-parse-advice ()
  "Disable advice on `org-habit-parse-todo'."
  (advice-remove 'org-habit-parse-todo #'org-habit-plus--around-parse-todo))
```

Update the mode definition to include parse advice (replace the existing `define-minor-mode`):

```elisp
;;;###autoload
(define-minor-mode org-habit-plus-mode
  "Minor mode for complex recurrence patterns in org-habit."
  :global t
  :lighter " Habit+"
  (if org-habit-plus-mode
      (progn
        (org-habit-plus--enable-advice)
        (org-habit-plus--enable-parse-advice))
    (org-habit-plus--disable-advice)
    (org-habit-plus--disable-parse-advice)))
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 10 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 11: Support "First Weekday of Month" Pattern

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for first-weekday pattern**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-first-weekday-of-month ()
  "Test first weekday of month pattern."
  (let ((rule (org-habit-plus--parse-recurrence "first weekday of month")))
    (assert-equal 'first-weekday (plist-get rule :type))
    (assert-equal t (plist-get rule :month)))
  ;; January 2024 starts on Monday, so first weekday is Jan 1
  (let* ((rule (org-habit-plus--parse-recurrence "first weekday of month"))
         (next (org-habit-plus--next-occurrence rule '(12 31 2023))))
    (assert-equal '(1 1 2024) next))
  ;; After Jan 1, next first weekday is Feb 1, 2024 (Thursday)
  (let* ((rule (org-habit-plus--parse-recurrence "first weekday of month"))
         (next (org-habit-plus--next-occurrence rule '(1 1 2024))))
    (assert-equal '(2 1 2024) next)))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL (parser doesn't recognize "first weekday")

**Step 3: Write minimal implementation**

Add regexp constant to `org-habit-plus.el` (after the other regexps):

```elisp
(defconst org-habit-plus--first-weekday-regexp
  "\\<\\(first\\|1st\\|last\\)\\s-+weekday\\s-+of\\s-+month\\>"
  "Regexp matching 'first/last weekday of month' pattern.")
```

Update `org-habit-plus--parse-recurrence` to handle this pattern (add this clause BEFORE the nth-weekday clause):

```elisp
     ;; First/last weekday of month
     ((string-match org-habit-plus--first-weekday-regexp str)
      (let ((which (match-string 1 str)))
        (list :type 'first-weekday
              :n (if (member which '("last")) -1 1)
              :month t)))
```

Add function to compute first weekday:

```elisp
(defun org-habit-plus--first-weekday-in-month (n month year)
  "Return the Nth weekday (Mon-Fri) in MONTH YEAR.
N=1 means first, N=-1 means last."
  (if (= n 1)
      ;; First weekday: find first day, adjust if weekend
      (let ((dow (calendar-day-of-week (list month 1 year))))
        (cond
         ((= dow 0) (list month 2 year))   ; Sunday -> Monday
         ((= dow 6) (list month 3 year))   ; Saturday -> Monday
         (t (list month 1 year))))         ; Already weekday
    ;; Last weekday: find last day, adjust if weekend
    (let* ((last-day (calendar-last-day-of-month month year))
           (dow (calendar-day-of-week (list month last-day year))))
      (cond
       ((= dow 0) (list month (- last-day 2) year))  ; Sunday -> Friday
       ((= dow 6) (list month (- last-day 1) year))  ; Saturday -> Friday
       (t (list month last-day year))))))            ; Already weekday

(defun org-habit-plus--next-first-weekday (rule from-date)
  "Compute next first/last weekday occurrence after FROM-DATE."
  (let* ((n (plist-get rule :n))
         (from-month (nth 0 from-date))
         (from-year (nth 2 from-date))
         (from-absolute (calendar-absolute-from-gregorian from-date))
         (candidate (org-habit-plus--first-weekday-in-month n from-month from-year))
         (candidate-absolute (calendar-absolute-from-gregorian candidate)))
    (if (> candidate-absolute from-absolute)
        candidate
      (let ((next-month (1+ from-month))
            (next-year from-year))
        (when (> next-month 12)
          (setq next-month 1)
          (setq next-year (1+ next-year)))
        (org-habit-plus--first-weekday-in-month n next-month next-year)))))
```

Update `org-habit-plus--next-occurrence` to handle first-weekday (add this clause):

```elisp
      ('first-weekday
       (org-habit-plus--next-first-weekday rule from-date))
```

Also update `org-habit-plus--approximate-interval` to handle first-weekday:

```elisp
      ('first-weekday
       ;; Monthly patterns average ~30 days
       30)
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 11 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 12: Support "Last Day of Month" Pattern

**Files:**
- Modify: `org-habit-plus.el`
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write failing test for last-day pattern**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-last-day-of-month ()
  "Test last day of month pattern."
  (let ((rule (org-habit-plus--parse-recurrence "last day of month")))
    (assert-equal 'last-day (plist-get rule :type)))
  ;; Last day of January 2024 is 31
  (let* ((rule (org-habit-plus--parse-recurrence "last day of month"))
         (next (org-habit-plus--next-occurrence rule '(1 1 2024))))
    (assert-equal '(1 31 2024) next))
  ;; After Jan 31, next is Feb 29 (2024 is leap year)
  (let* ((rule (org-habit-plus--parse-recurrence "last day of month"))
         (next (org-habit-plus--next-occurrence rule '(1 31 2024))))
    (assert-equal '(2 29 2024) next)))
```

**Step 2: Run test to verify it fails**

Run: `elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

Add to `org-habit-plus.el`:

```elisp
(defconst org-habit-plus--last-day-regexp
  "\\<last\\s-+day\\s-+of\\s-+month\\>"
  "Regexp matching 'last day of month' pattern.")
```

Update parser (add BEFORE the first-weekday clause):

```elisp
     ;; Last day of month
     ((string-match org-habit-plus--last-day-regexp str)
      (list :type 'last-day :month t))
```

Add handlers:

```elisp
(defun org-habit-plus--last-day-of-month (month year)
  "Return (MONTH DAY YEAR) for last day of MONTH in YEAR."
  (list month (calendar-last-day-of-month month year) year))

(defun org-habit-plus--next-last-day (_rule from-date)
  "Compute next last-day-of-month occurrence after FROM-DATE."
  (let* ((from-month (nth 0 from-date))
         (from-year (nth 2 from-date))
         (from-absolute (calendar-absolute-from-gregorian from-date))
         (candidate (org-habit-plus--last-day-of-month from-month from-year))
         (candidate-absolute (calendar-absolute-from-gregorian candidate)))
    (if (> candidate-absolute from-absolute)
        candidate
      (let ((next-month (1+ from-month))
            (next-year from-year))
        (when (> next-month 12)
          (setq next-month 1)
          (setq next-year (1+ next-year)))
        (org-habit-plus--last-day-of-month next-month next-year)))))
```

Update `org-habit-plus--next-occurrence` (add this clause):

```elisp
      ('last-day
       (org-habit-plus--next-last-day rule from-date))
```

Update `org-habit-plus--approximate-interval`:

```elisp
      ('last-day
       ;; Monthly patterns average ~30 days
       30)
```

**Step 4: Run test to verify it passes**

Run: `elk test`
Expected: 12 passed

**Step 5: DO NOT commit (user requested no git changes)**

---

## Task 13: Integration Test with Full Org Workflow

**Files:**
- Modify: `test/org-habit-plus-test.el`

**Step 1: Write integration test**

Add to `test/org-habit-plus-test.el`:

```elisp
(deftest test-full-workflow ()
  "Integration test: create habit, mark done, verify next scheduled."
  (let ((org-log-done nil)
        (org-log-repeat nil))
    (with-temp-buffer
      (org-mode)
      (insert "* TODO Monthly review\n")
      (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
      (insert ":PROPERTIES:\n")
      (insert ":STYLE: habit\n")
      (insert ":RECURRENCE: second saturday of month\n")
      (insert ":END:\n")
      (goto-char (point-min))
      (org-habit-plus-mode 1)
      ;; Verify initial state
      (assert-true (org-is-habit-p))
      (assert-true (org-habit-plus--get-recurrence))
      ;; Mark as DONE (this triggers org-auto-repeat-maybe)
      (org-todo "DONE")
      ;; State should return to TODO
      (assert-equal "TODO" (org-get-todo-state))
      ;; Should be scheduled for 2nd Saturday of February
      (let ((scheduled (org-entry-get nil "SCHEDULED")))
        (assert-match "2024-02-10" scheduled))
      (org-habit-plus-mode -1))))
```

**Step 2: Run test**

Run: `elk test`
Expected: 13 passed

**Step 3: DO NOT commit (user requested no git changes)**

---

## Task 14: Documentation and Autoload Cookies

**Files:**
- Modify: `org-habit-plus.el`

**Step 1: Add comprehensive docstrings and autoload cookies**

Ensure all public functions have `;;;###autoload` cookies where appropriate.

Update the Commentary section in `org-habit-plus.el`:

```elisp
;;; Commentary:

;; org-habit-plus extends org-habit to support complex recurrence patterns
;; that cannot be expressed with standard org repeaters.
;;
;; Supported patterns:
;;   - "second saturday of month"
;;   - "last friday of month"
;;   - "first weekday of month"
;;   - "last weekday of month"
;;   - "last day of month"
;;
;; Installation:
;;   (require 'org-habit-plus)
;;   (org-habit-plus-mode 1)
;;
;; Usage:
;;   Add a :RECURRENCE: property to your habit:
;;
;;   * TODO Monthly review
;;   SCHEDULED: <2024-01-13 Sat .+1m>
;;   :PROPERTIES:
;;   :STYLE: habit
;;   :RECURRENCE: second saturday of month
;;   :END:
;;
;; The SCHEDULED timestamp must have a repeater (e.g., .+1m) for org-habit
;; compatibility, but org-habit-plus will override it with the correct date
;; based on the RECURRENCE rule when you mark the task as DONE.
;;
;; The consistency graph will use an approximate interval based on the
;; recurrence pattern (monthly patterns show ~30 day intervals).
```

**Step 2: Run tests to ensure nothing broke**

Run: `elk test`
Expected: 13 passed

**Step 3: DO NOT commit (user requested no git changes)**

---

## Task 15: Create README

**Files:**
- Create: `README.org`

**Step 1: Create README**

```org
#+TITLE: org-habit-plus
#+AUTHOR: Your Name

Complex recurrence patterns for org-habit.

* Overview

org-habit-plus extends [[https://orgmode.org/manual/Tracking-your-habits.html][org-habit]] to support recurrence patterns that
cannot be expressed with standard org repeaters:

- "second saturday of month"
- "last friday of month"
- "first weekday of month"
- "last day of month"

* Installation

** From source

#+begin_src elisp
(add-to-list 'load-path "/path/to/org-habit-plus")
(require 'org-habit-plus)
(org-habit-plus-mode 1)
#+end_src

* Usage

Add a =:RECURRENCE:= property to your habit:

#+begin_src org
,* TODO Monthly review
SCHEDULED: <2024-01-13 Sat .+1m>
:PROPERTIES:
:STYLE: habit
:RECURRENCE: second saturday of month
:END:
#+end_src

When you mark the task as DONE, org-habit-plus calculates the next
occurrence based on your recurrence rule and updates the SCHEDULED
timestamp accordingly.

* Supported Patterns

| Pattern                      | Example                    |
|------------------------------+----------------------------|
| Nth weekday of month         | second saturday of month   |
| Last weekday of month        | last friday of month       |
| First/last weekday of month  | first weekday of month     |
| Last day of month            | last day of month          |

* How It Works

org-habit-plus uses Emacs advice to intercept two key org-habit functions:

1. =org-auto-repeat-maybe= - After marking DONE, computes the next
   occurrence using =calendar-nth-named-day= and updates SCHEDULED.

2. =org-habit-parse-todo= - Returns an approximate interval (~30 days
   for monthly patterns) so the consistency graph displays correctly.

* Development

This project uses [[https://codeberg.org/Trevoke/elk][Elk]] for task running and [[https://codeberg.org/Trevoke/e-unit.el][e-unit]] for testing.

#+begin_src bash
# Run tests
elk test

# Byte-compile
elk compile

# Clean build artifacts
elk clean
#+end_src

* License

GPL-3.0
#+end_src

**Step 2: DO NOT commit (user requested no git changes)**

---

## Summary

This plan implements org-habit-plus in 15 bite-sized tasks following TDD:

| Task | Description                                | Tests |
|------|--------------------------------------------|-------|
| 1    | Project skeleton + Elkfile                 | 0     |
| 2    | Ordinal/weekday parsing constants          | 2     |
| 3    | Recurrence rule parsing                    | 3     |
| 4    | Next occurrence calculation                | 4     |
| 5    | Get recurrence from org entry              | 5     |
| 6    | Date format conversions                    | 6     |
| 7    | Core repeat handler                        | 7     |
| 8    | Advice for org-auto-repeat-maybe           | 8     |
| 9    | Approximate interval for graphs            | 9     |
| 10   | Advice for org-habit-parse-todo            | 10    |
| 11   | First weekday of month support             | 11    |
| 12   | Last day of month support                  | 12    |
| 13   | Integration test                           | 13    |
| 14   | Documentation and autoloads                | 13    |
| 15   | README                                     | 13    |

Total: 13 e-unit tests covering all functionality.
