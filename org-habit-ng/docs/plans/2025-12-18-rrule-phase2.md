# Phase 2: Interactive RRULE Builder - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a progressive wizard UI for constructing RRULE strings without memorizing syntax.

**Architecture:** Step-by-step wizard collects recurrence parameters, builds RRULE string, shows preview with natural language description and next occurrences, then saves to :RECURRENCE: property. Transient.el for GUI, completing-read fallback for terminal.

**Tech Stack:** Transient.el, completing-read, org-habit-plus Phase 1 RRULE engine

---

## Task 1: RRULE Builder - Core Function

Build RRULE strings from component parts.

**Files:**
- Modify: `org-habit-plus.el` (add after line 913, before `provide`)
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-rrule-build-daily ()
  "Test building daily RRULE strings."
  (assert-equal "FREQ=DAILY;INTERVAL=1"
                (org-habit-plus--rrule-build '(:freq daily :interval 1)))
  (assert-equal "FREQ=DAILY;INTERVAL=3"
                (org-habit-plus--rrule-build '(:freq daily :interval 3))))

(deftest test-rrule-build-weekly ()
  "Test building weekly RRULE strings."
  (assert-equal "FREQ=WEEKLY;INTERVAL=1"
                (org-habit-plus--rrule-build '(:freq weekly :interval 1)))
  (assert-equal "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
                (org-habit-plus--rrule-build '(:freq weekly :interval 2 :byday (1 3 5)))))

(deftest test-rrule-build-monthly ()
  "Test building monthly RRULE strings."
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15"
                (org-habit-plus--rrule-build '(:freq monthly :interval 1 :bymonthday (15))))
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYDAY=2SA"
                (org-habit-plus--rrule-build '(:freq monthly :interval 1 :byday ((2 . 6)))))
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYDAY=-1FR"
                (org-habit-plus--rrule-build '(:freq monthly :interval 1 :byday ((-1 . 5))))))

(deftest test-rrule-build-yearly ()
  "Test building yearly RRULE strings."
  (assert-equal "FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYDAY=-1SU"
                (org-habit-plus--rrule-build '(:freq yearly :interval 1 :bymonth (12) :byday ((-1 . 0))))))

(deftest test-rrule-build-extensions ()
  "Test building RRULE with extensions."
  (assert-equal "FREQ=DAILY;INTERVAL=3;X-REPEAT-FROM=completion"
                (org-habit-plus--rrule-build '(:freq daily :interval 3 :repeat-from completion)))
  (assert-equal "FREQ=DAILY;INTERVAL=3;X-FLEXIBILITY=1"
                (org-habit-plus--rrule-build '(:freq daily :interval 3 :flexibility 1))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "Symbol's function definition is void: org-habit-plus--rrule-build"

**Step 3: Write minimal implementation**

```elisp
;;; RRULE Builder (Phase 2)

(defconst org-habit-plus--rrule-day-abbrevs
  ["SU" "MO" "TU" "WE" "TH" "FR" "SA"]
  "RRULE day abbreviations indexed by weekday number (0=Sunday).")

(defun org-habit-plus--rrule-build (rule)
  "Build RRULE string from RULE plist.
RULE can contain:
  :freq - daily, weekly, monthly, yearly
  :interval - repeat interval (default 1)
  :byday - list of weekday numbers or (ordinal . weekday) pairs
  :bymonthday - list of day numbers
  :bymonth - list of month numbers
  :repeat-from - completion or scheduled
  :flexibility - number of days"
  (let ((parts nil))
    ;; FREQ (required)
    (push (format "FREQ=%s" (upcase (symbol-name (plist-get rule :freq)))) parts)
    ;; INTERVAL
    (let ((interval (or (plist-get rule :interval) 1)))
      (push (format "INTERVAL=%d" interval) parts))
    ;; BYMONTH
    (when-let ((bymonth (plist-get rule :bymonth)))
      (push (format "BYMONTH=%s" (mapconcat #'number-to-string bymonth ",")) parts))
    ;; BYDAY
    (when-let ((byday (plist-get rule :byday)))
      (push (format "BYDAY=%s"
                    (mapconcat (lambda (d)
                                 (if (consp d)
                                     (format "%d%s" (car d) (aref org-habit-plus--rrule-day-abbrevs (cdr d)))
                                   (aref org-habit-plus--rrule-day-abbrevs d)))
                               byday ","))
            parts))
    ;; BYMONTHDAY
    (when-let ((bymonthday (plist-get rule :bymonthday)))
      (push (format "BYMONTHDAY=%s" (mapconcat #'number-to-string bymonthday ",")) parts))
    ;; X-REPEAT-FROM
    (when-let ((repeat-from (plist-get rule :repeat-from)))
      (push (format "X-REPEAT-FROM=%s" repeat-from) parts))
    ;; X-FLEXIBILITY
    (when-let ((flexibility (plist-get rule :flexibility)))
      (push (format "X-FLEXIBILITY=%d" flexibility) parts))
    ;; Join in correct order
    (string-join (nreverse parts) ";")))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: All rrule-build tests PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 2: Natural Language Generator

Convert RRULE plist to human-readable description.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-rrule-to-human-daily ()
  "Test daily RRULE to human-readable."
  (assert-equal "Every day"
                (org-habit-plus-rrule-to-human '(:freq daily :interval 1)))
  (assert-equal "Every 3 days"
                (org-habit-plus-rrule-to-human '(:freq daily :interval 3))))

(deftest test-rrule-to-human-weekly ()
  "Test weekly RRULE to human-readable."
  (assert-equal "Every week"
                (org-habit-plus-rrule-to-human '(:freq weekly :interval 1)))
  (assert-equal "Every 2 weeks"
                (org-habit-plus-rrule-to-human '(:freq weekly :interval 2)))
  (assert-equal "Every week on Monday, Wednesday, Friday"
                (org-habit-plus-rrule-to-human '(:freq weekly :interval 1 :byday (1 3 5)))))

(deftest test-rrule-to-human-monthly ()
  "Test monthly RRULE to human-readable."
  (assert-equal "Every month on day 15"
                (org-habit-plus-rrule-to-human '(:freq monthly :interval 1 :bymonthday (15))))
  (assert-equal "Every month on the 2nd Saturday"
                (org-habit-plus-rrule-to-human '(:freq monthly :interval 1 :byday ((2 . 6)))))
  (assert-equal "Every month on the last Friday"
                (org-habit-plus-rrule-to-human '(:freq monthly :interval 1 :byday ((-1 . 5)))))
  (assert-equal "Every month on the last day"
                (org-habit-plus-rrule-to-human '(:freq monthly :interval 1 :bymonthday (-1)))))

(deftest test-rrule-to-human-yearly ()
  "Test yearly RRULE to human-readable."
  (assert-equal "Every year in December on the last Sunday"
                (org-habit-plus-rrule-to-human '(:freq yearly :interval 1 :bymonth (12) :byday ((-1 . 0))))))

(deftest test-rrule-to-human-flexibility ()
  "Test flexibility window in human-readable output."
  (assert-equal "Every 3 days (within 1 day)"
                (org-habit-plus-rrule-to-human '(:freq daily :interval 3 :flexibility 1))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "Symbol's function definition is void: org-habit-plus-rrule-to-human"

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--weekday-names
  ["Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday"]
  "Full weekday names indexed by number (0=Sunday).")

(defconst org-habit-plus--month-names
  ["" "January" "February" "March" "April" "May" "June"
   "July" "August" "September" "October" "November" "December"]
  "Full month names indexed by number (1=January).")

(defconst org-habit-plus--ordinal-names
  '((1 . "1st") (2 . "2nd") (3 . "3rd") (4 . "4th") (5 . "5th")
    (-1 . "last") (-2 . "2nd to last"))
  "Ordinal number names for human output.")

(defun org-habit-plus-rrule-to-human (rule)
  "Convert RULE plist to human-readable string."
  (let* ((freq (plist-get rule :freq))
         (interval (or (plist-get rule :interval) 1))
         (byday (plist-get rule :byday))
         (bymonthday (plist-get rule :bymonthday))
         (bymonth (plist-get rule :bymonth))
         (flexibility (plist-get rule :flexibility))
         (base (org-habit-plus--rrule-freq-to-human freq interval)))
    ;; Add frequency-specific details
    (setq base
          (pcase freq
            ('daily base)
            ('weekly
             (if byday
                 (concat base " on "
                         (org-habit-plus--format-weekdays byday))
               base))
            ('monthly
             (cond
              ((and byday (consp (car byday)))
               (let* ((entry (car byday))
                      (ord (car entry))
                      (day (cdr entry)))
                 (concat base " on the "
                         (cdr (assoc ord org-habit-plus--ordinal-names)) " "
                         (aref org-habit-plus--weekday-names day))))
              (bymonthday
               (let ((d (car bymonthday)))
                 (if (= d -1)
                     (concat base " on the last day")
                   (concat base " on day " (number-to-string d)))))
              (t base)))
            ('yearly
             (let ((month-str (when bymonth
                                (aref org-habit-plus--month-names (car bymonth)))))
               (cond
                ((and bymonth byday (consp (car byday)))
                 (let* ((entry (car byday))
                        (ord (car entry))
                        (day (cdr entry)))
                   (concat base " in " month-str " on the "
                           (cdr (assoc ord org-habit-plus--ordinal-names)) " "
                           (aref org-habit-plus--weekday-names day))))
                (t base))))
            (_ base)))
    ;; Add flexibility suffix
    (when flexibility
      (setq base (concat base (format " (within %d day%s)"
                                      flexibility
                                      (if (= flexibility 1) "" "s")))))
    base))

(defun org-habit-plus--rrule-freq-to-human (freq interval)
  "Convert FREQ and INTERVAL to human-readable base string."
  (let ((unit (pcase freq
                ('daily "day")
                ('weekly "week")
                ('monthly "month")
                ('yearly "year")
                (_ "period"))))
    (if (= interval 1)
        (format "Every %s" unit)
      (format "Every %d %ss" interval unit))))

(defun org-habit-plus--format-weekdays (byday)
  "Format BYDAY list as human-readable weekday names."
  (mapconcat (lambda (d)
               (aref org-habit-plus--weekday-names d))
             byday ", "))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: All rrule-to-human tests PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 3: Next Occurrences Helper

Function to generate multiple future occurrences for preview.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-next-n-occurrences ()
  "Test generating multiple future occurrences."
  (let* ((rule '(:freq weekly :interval 1))
         (from '(:year 2024 :month 1 :day 1 :hour 0 :minute 0 :second 0))
         (occurrences (org-habit-plus-next-n-occurrences rule from 3)))
    (assert-equal 3 (length occurrences))
    ;; Weekly from Jan 1: Jan 8, Jan 15, Jan 22
    (assert-equal 8 (plist-get (nth 0 occurrences) :day))
    (assert-equal 15 (plist-get (nth 1 occurrences) :day))
    (assert-equal 22 (plist-get (nth 2 occurrences) :day))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL with "Symbol's function definition is void: org-habit-plus-next-n-occurrences"

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus-next-n-occurrences (rule from n)
  "Generate N future occurrences of RULE starting strictly after FROM.
Returns list of datetime plists."
  (let ((occurrences nil)
        (current from))
    (dotimes (_ n)
      (setq current (org-habit-plus--rrule-next-occurrence rule current))
      (when current
        (push current occurrences)))
    (nreverse occurrences)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 4: Format Occurrence for Display

Format datetime for preview display.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-format-occurrence ()
  "Test formatting datetime for display."
  (let ((dt '(:year 2024 :month 1 :day 13 :hour 0 :minute 0 :second 0)))
    (assert-equal "Sat Jan 13, 2024"
                  (org-habit-plus--format-occurrence dt))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--format-occurrence (dt)
  "Format datetime DT as human-readable date string."
  (let ((time (org-habit-plus--datetime-to-time dt)))
    (format-time-string "%a %b %d, %Y" time)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 5: Wizard State Management

Create structure to track wizard progress.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-state-init ()
  "Test wizard state initialization."
  (let ((state (org-habit-plus--wizard-state-create)))
    (assert-true (plist-get state :active))
    (assert-equal 1 (plist-get state :step))
    (assert-nil (plist-get state :freq))
    (assert-nil (plist-get state :interval))))

(deftest test-wizard-state-to-rule ()
  "Test converting wizard state to rule plist."
  (let ((state '(:active t :step 6
                 :freq weekly :interval 2
                 :byday (1 3 5)
                 :repeat-from scheduled)))
    (assert-equal '(:freq weekly :interval 2 :byday (1 3 5) :repeat-from scheduled)
                  (org-habit-plus--wizard-state-to-rule state))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
;;; Wizard State Management

(defvar org-habit-plus--wizard-state nil
  "Current state of the recurrence wizard.")

(defun org-habit-plus--wizard-state-create ()
  "Create initial wizard state."
  (list :active t
        :step 1
        :freq nil
        :interval nil
        :byday nil
        :bymonthday nil
        :bymonth nil
        :flexibility nil
        :repeat-from nil))

(defun org-habit-plus--wizard-state-to-rule (state)
  "Convert wizard STATE to rule plist for RRULE building."
  (let ((rule nil))
    (when-let ((freq (plist-get state :freq)))
      (setq rule (plist-put rule :freq freq)))
    (when-let ((interval (plist-get state :interval)))
      (setq rule (plist-put rule :interval interval)))
    (when-let ((byday (plist-get state :byday)))
      (setq rule (plist-put rule :byday byday)))
    (when-let ((bymonthday (plist-get state :bymonthday)))
      (setq rule (plist-put rule :bymonthday bymonthday)))
    (when-let ((bymonth (plist-get state :bymonth)))
      (setq rule (plist-put rule :bymonth bymonth)))
    (when-let ((flexibility (plist-get state :flexibility)))
      (setq rule (plist-put rule :flexibility flexibility)))
    (when-let ((repeat-from (plist-get state :repeat-from)))
      (setq rule (plist-put rule :repeat-from repeat-from)))
    rule))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 6: Wizard Step 1 - Frequency Selection (Completing-Read)

Implement frequency prompt using completing-read (fallback mode first).

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-frequency ()
  "Test frequency selection returns valid symbol."
  ;; Mock completing-read to return "Weekly"
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Weekly")))
    (assert-equal 'weekly (org-habit-plus--wizard-prompt-frequency))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
;;; Wizard Prompts (Completing-Read Fallback)

(defconst org-habit-plus--frequency-options
  '(("Daily" . daily)
    ("Weekly" . weekly)
    ("Monthly" . monthly)
    ("Yearly" . yearly)
    ("Custom RRULE..." . custom))
  "Frequency options for wizard.")

(defun org-habit-plus--wizard-prompt-frequency ()
  "Prompt user for recurrence frequency. Returns symbol."
  (let* ((choices (mapcar #'car org-habit-plus--frequency-options))
         (choice (completing-read "How often does this repeat? " choices nil t)))
    (cdr (assoc choice org-habit-plus--frequency-options))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 7: Wizard Step 2 - Interval Prompt

Implement interval number prompt.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-interval ()
  "Test interval prompt returns number."
  (cl-letf (((symbol-function 'read-number)
             (lambda (&rest _) 2)))
    (assert-equal 2 (org-habit-plus--wizard-prompt-interval 'weekly))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--wizard-prompt-interval (freq)
  "Prompt for interval based on FREQ. Returns number."
  (let ((unit (pcase freq
                ('daily "days")
                ('weekly "weeks")
                ('monthly "months")
                ('yearly "years")
                (_ "periods"))))
    (read-number (format "Every how many %s? " unit) 1)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 8: Wizard Step 3a - Weekly Day Selection

Implement weekday multi-select for weekly frequency.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-weekdays ()
  "Test weekday selection returns list of day numbers."
  (cl-letf (((symbol-function 'completing-read-multiple)
             (lambda (&rest _) '("Monday" "Wednesday" "Friday"))))
    (assert-equal '(1 3 5) (org-habit-plus--wizard-prompt-weekdays))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--weekday-options
  '(("Sunday" . 0) ("Monday" . 1) ("Tuesday" . 2) ("Wednesday" . 3)
    ("Thursday" . 4) ("Friday" . 5) ("Saturday" . 6))
  "Weekday options for wizard.")

(defun org-habit-plus--wizard-prompt-weekdays ()
  "Prompt for weekday selection. Returns sorted list of day numbers."
  (let* ((choices (mapcar #'car org-habit-plus--weekday-options))
         (selected (completing-read-multiple "Which days? " choices nil t)))
    (sort (mapcar (lambda (s) (cdr (assoc s org-habit-plus--weekday-options)))
                  selected)
          #'<)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 9: Wizard Step 3b - Monthly Day Type Selection

Implement monthly recurrence type selection.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-monthly-type ()
  "Test monthly type selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Specific day of month (e.g., the 15th)")))
    (assert-equal 'day-of-month (org-habit-plus--wizard-prompt-monthly-type))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--monthly-type-options
  '(("Specific day of month (e.g., the 15th)" . day-of-month)
    ("Nth weekday (e.g., 2nd Saturday)" . nth-weekday)
    ("Last specific weekday (e.g., last Friday)" . last-weekday)
    ("Last day of month" . last-day))
  "Monthly recurrence type options.")

(defun org-habit-plus--wizard-prompt-monthly-type ()
  "Prompt for monthly recurrence type. Returns symbol."
  (let* ((choices (mapcar #'car org-habit-plus--monthly-type-options))
         (choice (completing-read "Repeat on: " choices nil t)))
    (cdr (assoc choice org-habit-plus--monthly-type-options))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 10: Wizard Step 3b - Monthly Day Details

Implement prompts for specific monthly day options.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-day-of-month ()
  "Test day of month prompt."
  (cl-letf (((symbol-function 'read-number)
             (lambda (&rest _) 15)))
    (assert-equal '(:bymonthday (15))
                  (org-habit-plus--wizard-prompt-monthly-details 'day-of-month))))

(deftest test-wizard-prompt-nth-weekday ()
  "Test nth weekday prompt."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (prompt &rest _)
               (if (string-match "Which day" prompt) "Saturday" "Second"))))
    (assert-equal '(:byday ((2 . 6)))
                  (org-habit-plus--wizard-prompt-monthly-details 'nth-weekday))))

(deftest test-wizard-prompt-last-weekday ()
  "Test last weekday prompt."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Friday")))
    (assert-equal '(:byday ((-1 . 5)))
                  (org-habit-plus--wizard-prompt-monthly-details 'last-weekday))))

(deftest test-wizard-prompt-last-day ()
  "Test last day of month."
  (assert-equal '(:bymonthday (-1))
                (org-habit-plus--wizard-prompt-monthly-details 'last-day)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--ordinal-options
  '(("First" . 1) ("Second" . 2) ("Third" . 3) ("Fourth" . 4) ("Fifth" . 5))
  "Ordinal options for nth weekday selection.")

(defun org-habit-plus--wizard-prompt-monthly-details (type)
  "Prompt for monthly details based on TYPE. Returns partial rule plist."
  (pcase type
    ('day-of-month
     (let ((day (read-number "Which day of month? (1-31): " 1)))
       (list :bymonthday (list day))))
    ('nth-weekday
     (let* ((day-choices (mapcar #'car org-habit-plus--weekday-options))
            (day-name (completing-read "Which day? " day-choices nil t))
            (day-num (cdr (assoc day-name org-habit-plus--weekday-options)))
            (ord-choices (mapcar #'car org-habit-plus--ordinal-options))
            (ord-name (completing-read "Which occurrence? " ord-choices nil t))
            (ord-num (cdr (assoc ord-name org-habit-plus--ordinal-options))))
       (list :byday (list (cons ord-num day-num)))))
    ('last-weekday
     (let* ((day-choices (mapcar #'car org-habit-plus--weekday-options))
            (day-name (completing-read "Which day? " day-choices nil t))
            (day-num (cdr (assoc day-name org-habit-plus--weekday-options))))
       (list :byday (list (cons -1 day-num)))))
    ('last-day
     (list :bymonthday (list -1)))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 11: Wizard Step 3c - Yearly Month Selection

Implement month selection for yearly frequency.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-month ()
  "Test month selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "December")))
    (assert-equal 12 (org-habit-plus--wizard-prompt-month))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--month-options
  '(("January" . 1) ("February" . 2) ("March" . 3) ("April" . 4)
    ("May" . 5) ("June" . 6) ("July" . 7) ("August" . 8)
    ("September" . 9) ("October" . 10) ("November" . 11) ("December" . 12))
  "Month options for wizard.")

(defun org-habit-plus--wizard-prompt-month ()
  "Prompt for month selection. Returns month number (1-12)."
  (let* ((choices (mapcar #'car org-habit-plus--month-options))
         (choice (completing-read "Which month? " choices nil t)))
    (cdr (assoc choice org-habit-plus--month-options))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 12: Wizard Step 4 - Flexibility Window

Implement flexibility window prompt.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-flexibility-yes ()
  "Test flexibility prompt when user says yes."
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t))
            ((symbol-function 'read-number) (lambda (&rest _) 2)))
    (assert-equal 2 (org-habit-plus--wizard-prompt-flexibility))))

(deftest test-wizard-prompt-flexibility-no ()
  "Test flexibility prompt when user says no."
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) nil)))
    (assert-nil (org-habit-plus--wizard-prompt-flexibility))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--wizard-prompt-flexibility ()
  "Prompt for flexibility window. Returns number or nil."
  (when (y-or-n-p
         (concat "Add flexibility window?\n\n"
                 "  A flexibility window lets you complete the habit within N days\n"
                 "  of the scheduled date. Useful for habits that don't need exact\n"
                 "  timing, like \"water plants every 3 days, give or take a day.\"\n\n"
                 "Add flexibility window? "))
    (read-number "Complete within how many days of scheduled date? " 1)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 13: Wizard Step 5 - Repeat From

Implement repeat-from prompt.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-prompt-repeat-from ()
  "Test repeat-from selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Scheduled date")))
    (assert-equal 'scheduled (org-habit-plus--wizard-prompt-repeat-from))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defconst org-habit-plus--repeat-from-options
  '(("Scheduled date" . scheduled)
    ("Completion date" . completion))
  "Repeat-from options for wizard.")

(defun org-habit-plus--wizard-prompt-repeat-from ()
  "Prompt for repeat-from selection. Returns symbol."
  (let* ((prompt (concat "When you mark DONE, advance next occurrence from:\n\n"
                         "  Scheduled date\n"
                         "      If scheduled for Mon and you complete on Wed,\n"
                         "      next occurrence is calculated from Mon.\n\n"
                         "  Completion date\n"
                         "      If scheduled for Mon and you complete on Wed,\n"
                         "      next occurrence is calculated from Wed.\n\n"
                         "Advance from: "))
         (choices (mapcar #'car org-habit-plus--repeat-from-options))
         (choice (completing-read prompt choices nil t nil nil "Scheduled date")))
    (cdr (assoc choice org-habit-plus--repeat-from-options))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 14: Preview Display

Implement preview buffer showing rule details.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-format-preview ()
  "Test preview formatting."
  (let* ((rule '(:freq weekly :interval 2 :byday (1 3 5) :repeat-from scheduled))
         (preview (org-habit-plus--wizard-format-preview rule)))
    (assert-match "Every 2 weeks on Monday, Wednesday, Friday" preview)
    (assert-match "FREQ=WEEKLY" preview)
    (assert-match "Next 3 occurrences:" preview)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defcustom org-habit-plus-preview-occurrences 3
  "Number of future occurrences to show in preview."
  :type 'integer
  :group 'org-habit-plus)

(defun org-habit-plus--wizard-format-preview (rule)
  "Format RULE as preview string."
  (let* ((human (org-habit-plus-rrule-to-human rule))
         (rrule (org-habit-plus--rrule-build rule))
         (now (org-habit-plus--time-to-datetime (current-time)))
         (occurrences (org-habit-plus-next-n-occurrences rule now org-habit-plus-preview-occurrences))
         (occ-strings (mapcar #'org-habit-plus--format-occurrence occurrences)))
    (concat "Recurrence Preview\n"
            (make-string 18 ?─) "\n\n"
            "  " human "\n\n"
            "  RRULE: " rrule "\n\n"
            "  Next " (number-to-string org-habit-plus-preview-occurrences) " occurrences:\n"
            (mapconcat (lambda (s) (concat "    • " s)) occ-strings "\n")
            "\n")))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 15: Save Recurrence Property

Implement saving RRULE to org entry.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-save-recurrence ()
  "Test saving recurrence to org entry."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-plus--wizard-save-recurrence "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR")
    (assert-equal "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
                  (org-entry-get nil "RECURRENCE"))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--wizard-save-recurrence (rrule-string)
  "Save RRULE-STRING to current org entry's RECURRENCE property."
  (org-entry-put nil org-habit-plus-recurrence-property rrule-string))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 16: Main Wizard Flow (Completing-Read Version)

Wire up complete wizard using completing-read prompts.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-wizard-run-completing-read ()
  "Test complete wizard flow with completing-read."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Mock all prompts
    (cl-letf (((symbol-function 'completing-read)
               (lambda (prompt &rest _)
                 (cond
                  ((string-match "How often" prompt) "Weekly")
                  ((string-match "Advance from" prompt) "Scheduled date")
                  (t "Monday"))))
              ((symbol-function 'completing-read-multiple)
               (lambda (&rest _) '("Monday" "Friday")))
              ((symbol-function 'read-number)
               (lambda (&rest _) 1))
              ((symbol-function 'y-or-n-p)
               (lambda (prompt)
                 (not (string-match "flexibility" prompt))))
              ;; Skip preview confirmation
              ((symbol-function 'org-habit-plus--wizard-show-preview)
               (lambda (&rest _) t)))
      (org-habit-plus--wizard-run-completing-read)
      (assert-match "FREQ=WEEKLY"
                    (org-entry-get nil "RECURRENCE")))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defun org-habit-plus--wizard-run-completing-read ()
  "Run the recurrence wizard using completing-read prompts."
  (let ((state (org-habit-plus--wizard-state-create)))
    ;; Step 1: Frequency
    (let ((freq (org-habit-plus--wizard-prompt-frequency)))
      (if (eq freq 'custom)
          ;; Custom RRULE entry
          (let ((rrule (read-string "Enter RRULE: ")))
            (when (org-habit-plus--wizard-show-preview
                   (org-habit-plus--rrule-parse rrule))
              (org-habit-plus--wizard-save-recurrence rrule)))
        ;; Normal wizard flow
        (setq state (plist-put state :freq freq))
        ;; Step 2: Interval
        (setq state (plist-put state :interval
                               (org-habit-plus--wizard-prompt-interval freq)))
        ;; Step 3: Day constraints
        (pcase freq
          ('weekly
           (setq state (plist-put state :byday
                                  (org-habit-plus--wizard-prompt-weekdays))))
          ('monthly
           (let* ((type (org-habit-plus--wizard-prompt-monthly-type))
                  (details (org-habit-plus--wizard-prompt-monthly-details type)))
             (setq state (org-habit-plus--plist-merge state details))))
          ('yearly
           (setq state (plist-put state :bymonth
                                  (list (org-habit-plus--wizard-prompt-month))))
           (let* ((type (org-habit-plus--wizard-prompt-monthly-type))
                  (details (org-habit-plus--wizard-prompt-monthly-details type)))
             (setq state (org-habit-plus--plist-merge state details)))))
        ;; Step 4: Flexibility
        (when-let ((flex (org-habit-plus--wizard-prompt-flexibility)))
          (setq state (plist-put state :flexibility flex)))
        ;; Step 5: Repeat from
        (setq state (plist-put state :repeat-from
                               (org-habit-plus--wizard-prompt-repeat-from)))
        ;; Step 6: Preview and save
        (let ((rule (org-habit-plus--wizard-state-to-rule state)))
          (when (org-habit-plus--wizard-show-preview rule)
            (org-habit-plus--wizard-save-recurrence
             (org-habit-plus--rrule-build rule))))))))

(defun org-habit-plus--plist-merge (base additions)
  "Merge ADDITIONS plist into BASE plist."
  (let ((result (copy-sequence base)))
    (while additions
      (setq result (plist-put result (car additions) (cadr additions)))
      (setq additions (cddr additions)))
    result))

(defun org-habit-plus--wizard-show-preview (rule)
  "Show preview of RULE and prompt for confirmation.
Returns t if user confirms, nil to cancel."
  (let ((preview (org-habit-plus--wizard-format-preview rule)))
    (with-temp-buffer
      (insert preview)
      (insert "\n[y] Save  [n] Cancel  [e] Start over\n")
      (message "%s" (buffer-string)))
    (let ((response (read-char-choice "Save recurrence? [y/n/e]: " '(?y ?n ?e))))
      (pcase response
        (?y t)
        (?n nil)
        (?e (org-habit-plus--wizard-run-completing-read) nil)))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 17: Entry Point Command

Create the main interactive command.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-set-recurrence-command-exists ()
  "Test that the command is defined."
  (assert-true (commandp 'org-habit-plus-set-recurrence)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defcustom org-habit-plus-use-completing-read nil
  "When non-nil, use completing-read instead of transient menus.
When nil, auto-detect based on display capabilities."
  :type 'boolean
  :group 'org-habit-plus)

;;;###autoload
(defun org-habit-plus-set-recurrence ()
  "Set or modify the recurrence pattern for the current org heading.
Uses a progressive wizard to build an RRULE string."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not in org-mode"))
  (unless (org-at-heading-p)
    (org-back-to-heading t))
  ;; Check for existing recurrence
  (let ((existing (org-entry-get nil org-habit-plus-recurrence-property)))
    (if existing
        (org-habit-plus--wizard-handle-existing existing)
      ;; New recurrence
      (if (or org-habit-plus-use-completing-read
              (not (display-graphic-p)))
          (org-habit-plus--wizard-run-completing-read)
        ;; TODO: Transient version in future task
        (org-habit-plus--wizard-run-completing-read)))))

(defun org-habit-plus--wizard-handle-existing (rrule)
  "Handle existing RRULE - offer to modify or clear."
  (let* ((rule (org-habit-plus--rrule-parse rrule))
         (human (org-habit-plus-rrule-to-human rule))
         (choice (completing-read
                  (format "Current recurrence:\n  %s\n  RRULE: %s\n\nAction: "
                          human rrule)
                  '("Modify" "Clear" "Cancel") nil t)))
    (pcase choice
      ("Modify" (org-habit-plus--wizard-run-completing-read))
      ("Clear"
       (when (y-or-n-p "Remove recurrence? ")
         (org-entry-delete nil org-habit-plus-recurrence-property)
         (message "Recurrence removed.")))
      ("Cancel" (message "Cancelled.")))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 18: Transient Menu - Frequency Selection

Implement transient menu for frequency (GUI mode).

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-transient-frequency-menu-defined ()
  "Test that transient frequency menu is defined."
  (require 'transient nil t)
  (when (featurep 'transient)
    (assert-true (transient--lookup-command 'org-habit-plus--transient-frequency))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL (or skip if transient not available)

**Step 3: Write minimal implementation**

```elisp
;;; Transient UI (Optional GUI Enhancement)

(when (require 'transient nil t)

  (transient-define-prefix org-habit-plus--transient-frequency ()
    "Select recurrence frequency."
    ["How often does this repeat?"
     ("d" "Daily" org-habit-plus--transient-set-daily)
     ("w" "Weekly" org-habit-plus--transient-set-weekly)
     ("m" "Monthly" org-habit-plus--transient-set-monthly)
     ("y" "Yearly" org-habit-plus--transient-set-yearly)
     ("c" "Custom RRULE..." org-habit-plus--transient-set-custom)])

  (defun org-habit-plus--transient-set-daily ()
    "Set frequency to daily and continue wizard."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :freq 'daily))
    (org-habit-plus--transient-interval))

  (defun org-habit-plus--transient-set-weekly ()
    "Set frequency to weekly and continue wizard."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :freq 'weekly))
    (org-habit-plus--transient-interval))

  (defun org-habit-plus--transient-set-monthly ()
    "Set frequency to monthly and continue wizard."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :freq 'monthly))
    (org-habit-plus--transient-interval))

  (defun org-habit-plus--transient-set-yearly ()
    "Set frequency to yearly and continue wizard."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :freq 'yearly))
    (org-habit-plus--transient-interval))

  (defun org-habit-plus--transient-set-custom ()
    "Enter custom RRULE string."
    (interactive)
    (let ((rrule (read-string "Enter RRULE: ")))
      (when (org-habit-plus--wizard-show-preview
             (org-habit-plus--rrule-parse rrule))
        (org-habit-plus--wizard-save-recurrence rrule))))

  (defun org-habit-plus--transient-interval ()
    "Prompt for interval after frequency selection."
    (let* ((freq (plist-get org-habit-plus--wizard-state :freq))
           (interval (org-habit-plus--wizard-prompt-interval freq)))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :interval interval))
      ;; Continue to day constraints
      (pcase freq
        ('daily (org-habit-plus--transient-flexibility))
        ('weekly (org-habit-plus--transient-weekdays))
        ('monthly (org-habit-plus--transient-monthly-type))
        ('yearly (org-habit-plus--transient-yearly-month))))))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS (or skip)

**Step 5: Commit**

Skip (user preference)

---

## Task 19: Transient Menu - Weekday Toggle Picker

Implement toggle-style weekday selection for transient.

**Files:**
- Modify: `org-habit-plus.el`
- Test: `test/org-habit-plus-test.el`

**Step 1: Write the failing test**

```elisp
(deftest test-transient-weekday-toggle ()
  "Test weekday toggle state management."
  (let ((org-habit-plus--weekday-selection nil))
    (org-habit-plus--toggle-weekday 1)  ; Monday
    (assert-equal '(1) org-habit-plus--weekday-selection)
    (org-habit-plus--toggle-weekday 3)  ; Wednesday
    (assert-equal '(1 3) (sort org-habit-plus--weekday-selection #'<))
    (org-habit-plus--toggle-weekday 1)  ; Toggle Monday off
    (assert-equal '(3) org-habit-plus--weekday-selection)))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

```elisp
(defvar org-habit-plus--weekday-selection nil
  "Currently selected weekdays in toggle picker.")

(defun org-habit-plus--toggle-weekday (day)
  "Toggle DAY in weekday selection."
  (if (member day org-habit-plus--weekday-selection)
      (setq org-habit-plus--weekday-selection
            (delete day org-habit-plus--weekday-selection))
    (push day org-habit-plus--weekday-selection)))

(when (featurep 'transient)

  (transient-define-prefix org-habit-plus--transient-weekdays ()
    "Select weekdays for recurrence."
    :init-value (lambda (_) (setq org-habit-plus--weekday-selection nil))
    ["Which days? (toggle with letter, RET when done)"
     ""
     ("M" org-habit-plus--transient-toggle-mon
      :description (lambda () (org-habit-plus--weekday-desc 1 "Mon")))
     ("T" org-habit-plus--transient-toggle-tue
      :description (lambda () (org-habit-plus--weekday-desc 2 "Tue")))
     ("W" org-habit-plus--transient-toggle-wed
      :description (lambda () (org-habit-plus--weekday-desc 3 "Wed")))
     ("R" org-habit-plus--transient-toggle-thu
      :description (lambda () (org-habit-plus--weekday-desc 4 "Thu")))
     ("F" org-habit-plus--transient-toggle-fri
      :description (lambda () (org-habit-plus--weekday-desc 5 "Fri")))
     ("S" org-habit-plus--transient-toggle-sat
      :description (lambda () (org-habit-plus--weekday-desc 6 "Sat")))
     ("U" org-habit-plus--transient-toggle-sun
      :description (lambda () (org-habit-plus--weekday-desc 0 "Sun")))]
    [("RET" "Done" org-habit-plus--transient-weekdays-done)])

  (defun org-habit-plus--weekday-desc (day name)
    "Return description for DAY toggle showing NAME and selection state."
    (if (member day org-habit-plus--weekday-selection)
        (format "[X] %s" name)
      (format "[ ] %s" name)))

  (defun org-habit-plus--transient-toggle-mon () (interactive) (org-habit-plus--toggle-weekday 1))
  (defun org-habit-plus--transient-toggle-tue () (interactive) (org-habit-plus--toggle-weekday 2))
  (defun org-habit-plus--transient-toggle-wed () (interactive) (org-habit-plus--toggle-weekday 3))
  (defun org-habit-plus--transient-toggle-thu () (interactive) (org-habit-plus--toggle-weekday 4))
  (defun org-habit-plus--transient-toggle-fri () (interactive) (org-habit-plus--toggle-weekday 5))
  (defun org-habit-plus--transient-toggle-sat () (interactive) (org-habit-plus--toggle-weekday 6))
  (defun org-habit-plus--transient-toggle-sun () (interactive) (org-habit-plus--toggle-weekday 0))

  (defun org-habit-plus--transient-weekdays-done ()
    "Finish weekday selection and continue wizard."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :byday
                     (sort org-habit-plus--weekday-selection #'<)))
    (org-habit-plus--transient-flexibility)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 20: Wire Up Transient to Entry Point

Connect transient menus to main command.

**Files:**
- Modify: `org-habit-plus.el`

**Step 1: Write the failing test**

```elisp
(deftest test-set-recurrence-uses-transient-when-available ()
  "Test that transient is used in GUI mode when available."
  (when (and (featurep 'transient) (display-graphic-p))
    ;; Just verify the function exists and is callable
    (assert-true (functionp 'org-habit-plus--wizard-run-transient))))
```

**Step 2: Run test to verify it fails**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Write minimal implementation**

Update `org-habit-plus-set-recurrence`:

```elisp
;;;###autoload
(defun org-habit-plus-set-recurrence ()
  "Set or modify the recurrence pattern for the current org heading.
Uses a progressive wizard to build an RRULE string."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not in org-mode"))
  (unless (org-at-heading-p)
    (org-back-to-heading t))
  ;; Check for existing recurrence
  (let ((existing (org-entry-get nil org-habit-plus-recurrence-property)))
    (if existing
        (org-habit-plus--wizard-handle-existing existing)
      ;; New recurrence
      (org-habit-plus--wizard-run))))

(defun org-habit-plus--wizard-run ()
  "Run the appropriate wizard based on display and settings."
  (setq org-habit-plus--wizard-state (org-habit-plus--wizard-state-create))
  (if (and (not org-habit-plus-use-completing-read)
           (display-graphic-p)
           (featurep 'transient))
      (org-habit-plus--wizard-run-transient)
    (org-habit-plus--wizard-run-completing-read)))

(when (featurep 'transient)
  (defun org-habit-plus--wizard-run-transient ()
    "Run wizard using transient menus."
    (org-habit-plus--transient-frequency)))
```

**Step 4: Run test to verify it passes**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Skip (user preference)

---

## Task 21: Complete Transient Flow

Wire up remaining transient menus for monthly, yearly, flexibility, repeat-from.

**Files:**
- Modify: `org-habit-plus.el`

**Step 1: Write implementation**

```elisp
(when (featurep 'transient)

  ;; Monthly type selection
  (transient-define-prefix org-habit-plus--transient-monthly-type ()
    "Select monthly recurrence type."
    ["Repeat on:"
     ("d" "Specific day of month (e.g., the 15th)" org-habit-plus--transient-monthly-day)
     ("n" "Nth weekday (e.g., 2nd Saturday)" org-habit-plus--transient-monthly-nth)
     ("l" "Last specific weekday (e.g., last Friday)" org-habit-plus--transient-monthly-last)
     ("e" "Last day of month" org-habit-plus--transient-monthly-lastday)])

  (defun org-habit-plus--transient-monthly-day ()
    "Set monthly day-of-month and continue."
    (interactive)
    (let ((day (read-number "Which day of month? (1-31): " 1)))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :bymonthday (list day)))
      (org-habit-plus--transient-flexibility)))

  (defun org-habit-plus--transient-monthly-nth ()
    "Set monthly nth weekday and continue."
    (interactive)
    (let* ((day-name (completing-read "Which day? " (mapcar #'car org-habit-plus--weekday-options) nil t))
           (day-num (cdr (assoc day-name org-habit-plus--weekday-options)))
           (ord-name (completing-read "Which occurrence? " (mapcar #'car org-habit-plus--ordinal-options) nil t))
           (ord-num (cdr (assoc ord-name org-habit-plus--ordinal-options))))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :byday (list (cons ord-num day-num))))
      (org-habit-plus--transient-flexibility)))

  (defun org-habit-plus--transient-monthly-last ()
    "Set monthly last weekday and continue."
    (interactive)
    (let* ((day-name (completing-read "Which day? " (mapcar #'car org-habit-plus--weekday-options) nil t))
           (day-num (cdr (assoc day-name org-habit-plus--weekday-options))))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :byday (list (cons -1 day-num))))
      (org-habit-plus--transient-flexibility)))

  (defun org-habit-plus--transient-monthly-lastday ()
    "Set monthly last day and continue."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :bymonthday (list -1)))
    (org-habit-plus--transient-flexibility))

  ;; Yearly month selection
  (defun org-habit-plus--transient-yearly-month ()
    "Prompt for month and continue to day selection."
    (let ((month (org-habit-plus--wizard-prompt-month)))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :bymonth (list month)))
      (org-habit-plus--transient-monthly-type)))

  ;; Flexibility
  (transient-define-prefix org-habit-plus--transient-flexibility ()
    "Ask about flexibility window."
    ["Add flexibility window?\n\n  A flexibility window lets you complete the habit within N days\n  of the scheduled date. Useful for habits that don't need exact\n  timing, like \"water plants every 3 days, give or take a day.\""
     ""
     ("y" "Yes, add window" org-habit-plus--transient-flexibility-yes)
     ("n" "No, exact dates only" org-habit-plus--transient-flexibility-no)])

  (defun org-habit-plus--transient-flexibility-yes ()
    "Add flexibility window and continue."
    (interactive)
    (let ((days (read-number "Complete within how many days of scheduled date? " 1)))
      (setq org-habit-plus--wizard-state
            (plist-put org-habit-plus--wizard-state :flexibility days))
      (org-habit-plus--transient-repeat-from)))

  (defun org-habit-plus--transient-flexibility-no ()
    "Skip flexibility and continue."
    (interactive)
    (org-habit-plus--transient-repeat-from))

  ;; Repeat-from
  (transient-define-prefix org-habit-plus--transient-repeat-from ()
    "Select repeat-from option."
    ["When you mark DONE, advance next occurrence from:\n"
     ""
     ("s" "Scheduled date\n      If scheduled for Mon and you complete on Wed,\n      next occurrence is calculated from Mon."
      org-habit-plus--transient-repeat-scheduled)
     ""
     ("c" "Completion date\n      If scheduled for Mon and you complete on Wed,\n      next occurrence is calculated from Wed."
      org-habit-plus--transient-repeat-completion)])

  (defun org-habit-plus--transient-repeat-scheduled ()
    "Set repeat-from to scheduled and show preview."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :repeat-from 'scheduled))
    (org-habit-plus--transient-preview))

  (defun org-habit-plus--transient-repeat-completion ()
    "Set repeat-from to completion and show preview."
    (interactive)
    (setq org-habit-plus--wizard-state
          (plist-put org-habit-plus--wizard-state :repeat-from 'completion))
    (org-habit-plus--transient-preview))

  ;; Preview
  (defun org-habit-plus--transient-preview ()
    "Show preview and offer to save."
    (let ((rule (org-habit-plus--wizard-state-to-rule org-habit-plus--wizard-state)))
      (when (org-habit-plus--wizard-show-preview rule)
        (org-habit-plus--wizard-save-recurrence
         (org-habit-plus--rrule-build rule))
        (message "Recurrence saved!")))))
```

**Step 2: Run tests**

Run: `vendor/elk/elk test`
Expected: All tests PASS

**Step 3: Commit**

Skip (user preference)

---

## Summary

**21 tasks** implementing the Phase 2 interactive RRULE builder:

1. RRULE Builder - Core function
2. Natural language generator
3. Next N occurrences helper
4. Format occurrence for display
5. Wizard state management
6. Frequency selection prompt
7. Interval prompt
8. Weekly day selection
9. Monthly type selection
10. Monthly day details
11. Yearly month selection
12. Flexibility window prompt
13. Repeat-from prompt
14. Preview display
15. Save recurrence property
16. Main wizard flow (completing-read)
17. Entry point command
18. Transient frequency menu
19. Transient weekday toggle
20. Wire up transient to entry
21. Complete transient flow

**Test command:** `vendor/elk/elk test`

**Entry point:** `M-x org-habit-plus-set-recurrence`
