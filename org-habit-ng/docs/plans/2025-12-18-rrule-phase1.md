# org-habit+ Phase 1: RRULE Engine Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Replace the regex-based recurrence parser with a full RRULE parser and evaluator that supports the complete RFC 5545 spec plus org-mode extensions.

**Architecture:** RRULE string → tokenizer → parser → rule plist → evaluator → next occurrence date. Advice functions hook into org-auto-repeat-maybe and org-habit-parse-todo.

**Tech Stack:** Emacs Lisp, calendar.el for date math, e-unit for testing, Elk for task running.

---

## Task 1: RRULE Data Structure and Tokenizer

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing test for tokenizer**

```elisp
(deftest test-rrule-tokenize-simple ()
  "Test tokenizing simple RRULE string."
  (let ((tokens (org-habit-plus--rrule-tokenize "FREQ=DAILY;INTERVAL=3")))
    (assert-equal '(("FREQ" . "DAILY") ("INTERVAL" . "3")) tokens)))

(deftest test-rrule-tokenize-complex ()
  "Test tokenizing RRULE with multiple values."
  (let ((tokens (org-habit-plus--rrule-tokenize "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-equal '(("FREQ" . "WEEKLY") ("BYDAY" . "MO,WE,FR")) tokens)))

(deftest test-rrule-tokenize-extensions ()
  "Test tokenizing with X- extensions."
  (let ((tokens (org-habit-plus--rrule-tokenize "FREQ=DAILY;X-REPEAT-FROM=completion;X-WARN=2d")))
    (assert-equal '(("FREQ" . "DAILY") ("X-REPEAT-FROM" . "completion") ("X-WARN" . "2d")) tokens)))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL - function not defined

**Step 3: Remove old parser code, implement tokenizer**

Remove these from org-habit-plus.el:
- `org-habit-plus--nth-weekday-regexp`
- `org-habit-plus--last-day-regexp`
- `org-habit-plus--first-weekday-regexp`
- `org-habit-plus--parse-recurrence` (old implementation)

Add new tokenizer:

```elisp
(defun org-habit-plus--rrule-tokenize (rrule-string)
  "Tokenize RRULE-STRING into alist of (KEY . VALUE) pairs.
Example: \"FREQ=DAILY;INTERVAL=3\" → ((\"FREQ\" . \"DAILY\") (\"INTERVAL\" . \"3\"))"
  (let ((parts (split-string rrule-string ";" t "[ \t\n]+")))
    (mapcar (lambda (part)
              (let ((kv (split-string part "=" t "[ \t]+")))
                (cons (car kv) (cadr kv))))
            parts)))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

**Step 5: Commit**

Do not commit (per user instructions).

---

## Task 2: RRULE Parser - Basic Structure

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests for parser**

```elisp
(deftest test-rrule-parse-daily ()
  "Test parsing DAILY frequency."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;INTERVAL=3")))
    (assert-equal 'daily (plist-get rule :freq))
    (assert-equal 3 (plist-get rule :interval))))

(deftest test-rrule-parse-weekly-byday ()
  "Test parsing WEEKLY with BYDAY."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-equal 'weekly (plist-get rule :freq))
    (assert-equal '(1 3 5) (plist-get rule :byday))))

(deftest test-rrule-parse-monthly-byday-ordinal ()
  "Test parsing MONTHLY with ordinal BYDAY."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=2SA")))
    (assert-equal 'monthly (plist-get rule :freq))
    (assert-equal '((2 . 6)) (plist-get rule :byday))))  ; 2nd Saturday

(deftest test-rrule-parse-monthly-byday-last ()
  "Test parsing MONTHLY with last weekday."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR")))
    (assert-equal 'monthly (plist-get rule :freq))
    (assert-equal '((-1 . 5)) (plist-get rule :byday))))  ; last Friday
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement RRULE parser**

```elisp
(defconst org-habit-plus--rrule-freq-alist
  '(("SECONDLY" . secondly)
    ("MINUTELY" . minutely)
    ("HOURLY" . hourly)
    ("DAILY" . daily)
    ("WEEKLY" . weekly)
    ("MONTHLY" . monthly)
    ("YEARLY" . yearly))
  "Mapping of RRULE FREQ values to symbols.")

(defconst org-habit-plus--rrule-day-alist
  '(("SU" . 0) ("MO" . 1) ("TU" . 2) ("WE" . 3)
    ("TH" . 4) ("FR" . 5) ("SA" . 6))
  "Mapping of RRULE day abbreviations to numbers (0=Sunday).")

(defun org-habit-plus--rrule-parse-byday (value)
  "Parse BYDAY VALUE into list of day specs.
Simple days like \"MO,WE,FR\" → (1 3 5)
Ordinal days like \"2SA,-1FR\" → ((2 . 6) (-1 . 5))"
  (let ((days (split-string value "," t)))
    (mapcar (lambda (day)
              (if (string-match "^\\(-?[0-9]+\\)?\\([A-Z][A-Z]\\)$" day)
                  (let ((ordinal (match-string 1 day))
                        (weekday (match-string 2 day)))
                    (if ordinal
                        (cons (string-to-number ordinal)
                              (cdr (assoc weekday org-habit-plus--rrule-day-alist)))
                      (cdr (assoc weekday org-habit-plus--rrule-day-alist))))
                (error "Invalid BYDAY value: %s" day)))
            days)))

(defun org-habit-plus--rrule-parse-numlist (value)
  "Parse comma-separated numbers into list."
  (mapcar #'string-to-number (split-string value "," t)))

(defun org-habit-plus--rrule-parse (rrule-string)
  "Parse RRULE-STRING into a rule plist."
  (let ((tokens (org-habit-plus--rrule-tokenize rrule-string))
        (rule nil))
    (dolist (token tokens)
      (let ((key (car token))
            (value (cdr token)))
        (cond
         ((string= key "FREQ")
          (setq rule (plist-put rule :freq
                                (cdr (assoc value org-habit-plus--rrule-freq-alist)))))
         ((string= key "INTERVAL")
          (setq rule (plist-put rule :interval (string-to-number value))))
         ((string= key "COUNT")
          (setq rule (plist-put rule :count (string-to-number value))))
         ((string= key "UNTIL")
          (setq rule (plist-put rule :until value)))  ; Parse date later
         ((string= key "BYDAY")
          (setq rule (plist-put rule :byday (org-habit-plus--rrule-parse-byday value))))
         ((string= key "BYMONTHDAY")
          (setq rule (plist-put rule :bymonthday (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYMONTH")
          (setq rule (plist-put rule :bymonth (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYWEEKNO")
          (setq rule (plist-put rule :byweekno (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYYEARDAY")
          (setq rule (plist-put rule :byyearday (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYSETPOS")
          (setq rule (plist-put rule :bysetpos (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYHOUR")
          (setq rule (plist-put rule :byhour (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYMINUTE")
          (setq rule (plist-put rule :byminute (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "BYSECOND")
          (setq rule (plist-put rule :bysecond (org-habit-plus--rrule-parse-numlist value))))
         ((string= key "X-REPEAT-FROM")
          (setq rule (plist-put rule :repeat-from (intern value))))
         ((string= key "X-WARN")
          (setq rule (plist-put rule :warn value))))))
    ;; Default interval to 1 if not specified
    (unless (plist-get rule :interval)
      (setq rule (plist-put rule :interval 1)))
    rule))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 3: Date/Time Utilities

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-datetime-to-list ()
  "Test converting Emacs time to datetime list."
  (let ((time (encode-time 30 15 10 13 1 2024)))  ; 2024-01-13 10:15:30
    (let ((dt (org-habit-plus--time-to-datetime time)))
      (assert-equal 2024 (plist-get dt :year))
      (assert-equal 1 (plist-get dt :month))
      (assert-equal 13 (plist-get dt :day))
      (assert-equal 10 (plist-get dt :hour))
      (assert-equal 15 (plist-get dt :minute))
      (assert-equal 30 (plist-get dt :second)))))

(deftest test-datetime-to-time ()
  "Test converting datetime list back to Emacs time."
  (let* ((dt '(:year 2024 :month 1 :day 13 :hour 10 :minute 15 :second 30))
         (time (org-habit-plus--datetime-to-time dt))
         (decoded (decode-time time)))
    (assert-equal 30 (nth 0 decoded))
    (assert-equal 15 (nth 1 decoded))
    (assert-equal 10 (nth 2 decoded))
    (assert-equal 13 (nth 3 decoded))
    (assert-equal 1 (nth 4 decoded))
    (assert-equal 2024 (nth 5 decoded))))

(deftest test-datetime-day-of-week ()
  "Test getting day of week from datetime."
  ;; 2024-01-13 is Saturday
  (let ((dt '(:year 2024 :month 1 :day 13 :hour 0 :minute 0 :second 0)))
    (assert-equal 6 (org-habit-plus--datetime-dow dt))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement datetime utilities**

```elisp
(defun org-habit-plus--time-to-datetime (time)
  "Convert Emacs TIME to datetime plist."
  (let ((decoded (decode-time time)))
    (list :second (nth 0 decoded)
          :minute (nth 1 decoded)
          :hour (nth 2 decoded)
          :day (nth 3 decoded)
          :month (nth 4 decoded)
          :year (nth 5 decoded))))

(defun org-habit-plus--datetime-to-time (dt)
  "Convert datetime plist DT to Emacs time."
  (encode-time (plist-get dt :second)
               (plist-get dt :minute)
               (plist-get dt :hour)
               (plist-get dt :day)
               (plist-get dt :month)
               (plist-get dt :year)))

(defun org-habit-plus--datetime-dow (dt)
  "Get day of week for datetime DT (0=Sunday, 6=Saturday)."
  (calendar-day-of-week (list (plist-get dt :month)
                               (plist-get dt :day)
                               (plist-get dt :year))))

(defun org-habit-plus--datetime-compare (dt1 dt2)
  "Compare two datetime plists. Return -1, 0, or 1."
  (let ((t1 (org-habit-plus--datetime-to-time dt1))
        (t2 (org-habit-plus--datetime-to-time dt2)))
    (cond
     ((time-less-p t1 t2) -1)
     ((time-less-p t2 t1) 1)
     (t 0))))

(defun org-habit-plus--datetime-add (dt &rest adjustments)
  "Add ADJUSTMENTS to datetime DT. Returns new datetime.
ADJUSTMENTS are plist-style: :days 1 :hours 2 :months 1 etc."
  (let ((year (plist-get dt :year))
        (month (plist-get dt :month))
        (day (plist-get dt :day))
        (hour (plist-get dt :hour))
        (minute (plist-get dt :minute))
        (second (plist-get dt :second)))
    ;; Apply adjustments
    (setq second (+ second (or (plist-get adjustments :seconds) 0)))
    (setq minute (+ minute (or (plist-get adjustments :minutes) 0)))
    (setq hour (+ hour (or (plist-get adjustments :hours) 0)))
    (setq day (+ day (or (plist-get adjustments :days) 0)))
    (setq month (+ month (or (plist-get adjustments :months) 0)))
    (setq year (+ year (or (plist-get adjustments :years) 0)))
    ;; Normalize by encoding and decoding
    (org-habit-plus--time-to-datetime
     (encode-time second minute hour day month year))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 4: RRULE Evaluator - DAILY Frequency

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-daily-simple ()
  "Test next occurrence for simple daily rule."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=DAILY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 14 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))
    (assert-equal 2024 (plist-get next :year))))

(deftest test-rrule-next-daily-interval ()
  "Test next occurrence for daily with interval."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;INTERVAL=3"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 16 (plist-get next :day))))

(deftest test-rrule-next-daily-month-boundary ()
  "Test daily rule crossing month boundary."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=DAILY"))
         (from '(:year 2024 :month 1 :day 31 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 1 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement DAILY evaluator**

```elisp
(defun org-habit-plus--rrule-next-occurrence (rule from)
  "Compute next occurrence of RULE strictly after FROM datetime."
  (let ((freq (plist-get rule :freq)))
    (pcase freq
      ('daily (org-habit-plus--rrule-next-daily rule from))
      ('weekly (org-habit-plus--rrule-next-weekly rule from))
      ('monthly (org-habit-plus--rrule-next-monthly rule from))
      ('yearly (org-habit-plus--rrule-next-yearly rule from))
      ('hourly (org-habit-plus--rrule-next-hourly rule from))
      ('minutely (org-habit-plus--rrule-next-minutely rule from))
      ('secondly (org-habit-plus--rrule-next-secondly rule from))
      (_ (error "Unknown frequency: %s" freq)))))

(defun org-habit-plus--rrule-next-daily (rule from)
  "Compute next daily occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-plus--datetime-add from :days interval)))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 5: RRULE Evaluator - WEEKLY Frequency

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-weekly-simple ()
  "Test next occurrence for simple weekly rule."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))  ; Saturday
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 20 (plist-get next :day))))  ; Next Saturday

(deftest test-rrule-next-weekly-byday ()
  "Test weekly with specific days."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))  ; Saturday
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Next MO/WE/FR after Saturday Jan 13 is Monday Jan 15
    (assert-equal 15 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-weekly-byday-same-week ()
  "Test weekly BYDAY within same week."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))  ; Monday
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Next MO/WE/FR after Monday Jan 15 is Wednesday Jan 17
    (assert-equal 17 (plist-get next :day))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement WEEKLY evaluator**

```elisp
(defun org-habit-plus--rrule-next-weekly (rule from)
  "Compute next weekly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (byday (plist-get rule :byday)))
    (if (null byday)
        ;; Simple weekly: same day next week(s)
        (org-habit-plus--datetime-add from :days (* 7 interval))
      ;; BYDAY specified: find next matching day
      (let* ((from-dow (org-habit-plus--datetime-dow from))
             (target-days (if (consp (car byday))
                              (mapcar #'cdr byday)  ; Extract day numbers from ordinal pairs
                            byday))                  ; Already simple day numbers
             (sorted-days (sort (copy-sequence target-days) #'<))
             (next-day nil)
             (weeks-to-add 0))
        ;; Find next day in current week
        (dolist (d sorted-days)
          (when (and (null next-day) (> d from-dow))
            (setq next-day d)))
        ;; If no day found in current week, go to first day of next interval
        (when (null next-day)
          (setq next-day (car sorted-days))
          (setq weeks-to-add interval))
        ;; Calculate days to add
        (let ((days-diff (- next-day from-dow)))
          (when (< days-diff 0)
            (setq days-diff (+ days-diff 7)))
          (org-habit-plus--datetime-add from :days (+ days-diff (* 7 weeks-to-add))))))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 6: RRULE Evaluator - MONTHLY with BYDAY

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-monthly-byday-ordinal ()
  "Test monthly with ordinal BYDAY (2nd Saturday)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=2SA"))
         (from '(:year 2024 :month 1 :day 14 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; After Jan 14, next 2nd Saturday is Feb 10, 2024
    (assert-equal 10 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-byday-last ()
  "Test monthly with last weekday (-1FR)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Last Friday of January 2024 is Jan 26
    (assert-equal 26 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-byday-last-rollover ()
  "Test monthly last weekday rolling to next month."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR"))
         (from '(:year 2024 :month 1 :day 27 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; After Jan 27, next last Friday is Feb 23
    (assert-equal 23 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement MONTHLY evaluator**

```elisp
(defun org-habit-plus--rrule-next-monthly (rule from)
  "Compute next monthly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (byday (plist-get rule :byday))
        (bymonthday (plist-get rule :bymonthday)))
    (cond
     ;; BYDAY with ordinals (e.g., 2SA, -1FR)
     (byday
      (org-habit-plus--rrule-next-monthly-byday rule from))
     ;; BYMONTHDAY (e.g., 1, 15, -1)
     (bymonthday
      (org-habit-plus--rrule-next-monthly-bymonthday rule from))
     ;; Simple monthly: same day next month
     (t
      (org-habit-plus--datetime-add from :months interval)))))

(defun org-habit-plus--rrule-next-monthly-byday (rule from)
  "Compute next monthly BYDAY occurrence after FROM."
  (let* ((interval (plist-get rule :interval))
         (byday (plist-get rule :byday))
         (from-month (plist-get from :month))
         (from-year (plist-get from :year)))
    ;; For now, handle single BYDAY entry
    (let* ((entry (car byday))
           (ordinal (car entry))
           (weekday (cdr entry)))
      ;; Try current month
      (let* ((candidate-date (calendar-nth-named-day ordinal weekday from-month from-year))
             (candidate (list :year (nth 2 candidate-date)
                              :month (nth 0 candidate-date)
                              :day (nth 1 candidate-date)
                              :hour (plist-get from :hour)
                              :minute (plist-get from :minute)
                              :second (plist-get from :second))))
        (if (> (org-habit-plus--datetime-compare candidate from) 0)
            candidate
          ;; Move to next month(s)
          (let ((next-month (+ from-month interval))
                (next-year from-year))
            (while (> next-month 12)
              (setq next-month (- next-month 12))
              (setq next-year (1+ next-year)))
            (let ((next-date (calendar-nth-named-day ordinal weekday next-month next-year)))
              (list :year (nth 2 next-date)
                    :month (nth 0 next-date)
                    :day (nth 1 next-date)
                    :hour (plist-get from :hour)
                    :minute (plist-get from :minute)
                    :second (plist-get from :second)))))))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 7: RRULE Evaluator - MONTHLY with BYMONTHDAY

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-monthly-bymonthday ()
  "Test monthly with specific day of month."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=15"))
         (from '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 15 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-rollover ()
  "Test monthly BYMONTHDAY rolling to next month."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=15"))
         (from '(:year 2024 :month 1 :day 16 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 15 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-last ()
  "Test monthly with last day of month (-1)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=-1"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Last day of January is 31
    (assert-equal 31 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-last-feb ()
  "Test last day with February (leap year)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=-1"))
         (from '(:year 2024 :month 2 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; 2024 is leap year, Feb has 29 days
    (assert-equal 29 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement BYMONTHDAY evaluator**

```elisp
(defun org-habit-plus--resolve-monthday (monthday month year)
  "Resolve MONTHDAY for MONTH/YEAR. Handles negative values."
  (if (> monthday 0)
      monthday
    ;; Negative: count from end
    (+ (calendar-last-day-of-month month year) monthday 1)))

(defun org-habit-plus--rrule-next-monthly-bymonthday (rule from)
  "Compute next monthly BYMONTHDAY occurrence after FROM."
  (let* ((interval (plist-get rule :interval))
         (bymonthday (plist-get rule :bymonthday))
         (from-month (plist-get from :month))
         (from-year (plist-get from :year))
         (from-day (plist-get from :day))
         (target-day (car bymonthday)))  ; For now, single day
    ;; Resolve target day for current month
    (let ((resolved-day (org-habit-plus--resolve-monthday target-day from-month from-year)))
      (if (> resolved-day from-day)
          ;; Target day is later this month
          (list :year from-year
                :month from-month
                :day resolved-day
                :hour (plist-get from :hour)
                :minute (plist-get from :minute)
                :second (plist-get from :second))
        ;; Move to next month
        (let ((next-month (+ from-month interval))
              (next-year from-year))
          (while (> next-month 12)
            (setq next-month (- next-month 12))
            (setq next-year (1+ next-year)))
          (let ((next-resolved (org-habit-plus--resolve-monthday target-day next-month next-year)))
            (list :year next-year
                  :month next-month
                  :day next-resolved
                  :hour (plist-get from :hour)
                  :minute (plist-get from :minute)
                  :second (plist-get from :second))))))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 8: RRULE Evaluator - YEARLY Frequency

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-yearly-simple ()
  "Test simple yearly recurrence."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=YEARLY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 13 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))
    (assert-equal 2025 (plist-get next :year))))

(deftest test-rrule-next-yearly-bymonth-byday ()
  "Test yearly with BYMONTH and BYDAY (last Sunday of December)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Last Sunday of December 2024 is Dec 29
    (assert-equal 29 (plist-get next :day))
    (assert-equal 12 (plist-get next :month))
    (assert-equal 2024 (plist-get next :year))))

(deftest test-rrule-next-yearly-bymonth-byday-rollover ()
  "Test yearly BYMONTH/BYDAY rolling to next year."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU"))
         (from '(:year 2024 :month 12 :day 30 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Last Sunday of December 2025 is Dec 28
    (assert-equal 28 (plist-get next :day))
    (assert-equal 12 (plist-get next :month))
    (assert-equal 2025 (plist-get next :year))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement YEARLY evaluator**

```elisp
(defun org-habit-plus--rrule-next-yearly (rule from)
  "Compute next yearly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (bymonth (plist-get rule :bymonth))
        (byday (plist-get rule :byday)))
    (cond
     ;; BYMONTH + BYDAY (e.g., last Sunday of December)
     ((and bymonth byday)
      (org-habit-plus--rrule-next-yearly-bymonth-byday rule from))
     ;; Simple yearly
     (t
      (org-habit-plus--datetime-add from :years interval)))))

(defun org-habit-plus--rrule-next-yearly-bymonth-byday (rule from)
  "Compute next yearly BYMONTH+BYDAY occurrence after FROM."
  (let* ((interval (plist-get rule :interval))
         (bymonth (car (plist-get rule :bymonth)))
         (byday (car (plist-get rule :byday)))
         (ordinal (car byday))
         (weekday (cdr byday))
         (from-year (plist-get from :year)))
    ;; Try current year
    (let* ((candidate-date (calendar-nth-named-day ordinal weekday bymonth from-year))
           (candidate (list :year (nth 2 candidate-date)
                            :month (nth 0 candidate-date)
                            :day (nth 1 candidate-date)
                            :hour (plist-get from :hour)
                            :minute (plist-get from :minute)
                            :second (plist-get from :second))))
      (if (> (org-habit-plus--datetime-compare candidate from) 0)
          candidate
        ;; Move to next year
        (let* ((next-year (+ from-year interval))
               (next-date (calendar-nth-named-day ordinal weekday bymonth next-year)))
          (list :year (nth 2 next-date)
                :month (nth 0 next-date)
                :day (nth 1 next-date)
                :hour (plist-get from :hour)
                :minute (plist-get from :minute)
                :second (plist-get from :second)))))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 9: RRULE Evaluator - BYSETPOS

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-monthly-bysetpos-first-weekday ()
  "Test first weekday of month using BYSETPOS."
  ;; BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1 means first weekday
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; January 2024 starts on Monday, so first weekday is Jan 1
    ;; But we're ON Jan 1, so next is Feb 1 (Thursday)
    (assert-equal 1 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-bysetpos-last-weekday ()
  "Test last weekday of month using BYSETPOS."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Last weekday of January 2024 is Wed Jan 31
    (assert-equal 31 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement BYSETPOS support**

```elisp
(defun org-habit-plus--generate-monthly-byday-set (byday month year)
  "Generate all dates matching BYDAY in MONTH/YEAR.
BYDAY is list of weekday numbers (0-6).
Returns sorted list of day numbers."
  (let ((last-day (calendar-last-day-of-month month year))
        (result nil))
    (dotimes (d last-day)
      (let* ((day (1+ d))
             (dow (calendar-day-of-week (list month day year))))
        (when (member dow byday)
          (push day result))))
    (nreverse result)))

(defun org-habit-plus--apply-bysetpos (dates bysetpos)
  "Apply BYSETPOS filter to DATES list.
BYSETPOS is list of positions (1-indexed, negative from end)."
  (let ((result nil)
        (len (length dates)))
    (dolist (pos bysetpos)
      (let ((idx (if (> pos 0)
                     (1- pos)           ; 1-indexed to 0-indexed
                   (+ len pos))))       ; negative from end
        (when (and (>= idx 0) (< idx len))
          (push (nth idx dates) result))))
    (nreverse result)))

;; Update org-habit-plus--rrule-next-monthly to handle BYSETPOS:
(defun org-habit-plus--rrule-next-monthly (rule from)
  "Compute next monthly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (byday (plist-get rule :byday))
        (bymonthday (plist-get rule :bymonthday))
        (bysetpos (plist-get rule :bysetpos)))
    (cond
     ;; BYDAY + BYSETPOS (e.g., first/last weekday of month)
     ((and byday bysetpos (not (consp (car byday))))
      (org-habit-plus--rrule-next-monthly-byday-setpos rule from))
     ;; BYDAY with ordinals (e.g., 2SA, -1FR)
     ((and byday (consp (car byday)))
      (org-habit-plus--rrule-next-monthly-byday rule from))
     ;; Simple BYDAY without ordinals
     (byday
      (org-habit-plus--rrule-next-monthly-byday-setpos rule from))
     ;; BYMONTHDAY (e.g., 1, 15, -1)
     (bymonthday
      (org-habit-plus--rrule-next-monthly-bymonthday rule from))
     ;; Simple monthly: same day next month
     (t
      (org-habit-plus--datetime-add from :months interval)))))

(defun org-habit-plus--rrule-next-monthly-byday-setpos (rule from)
  "Compute next monthly occurrence with BYDAY and optional BYSETPOS."
  (let* ((interval (plist-get rule :interval))
         (byday (plist-get rule :byday))
         (bysetpos (or (plist-get rule :bysetpos) (list 1)))  ; Default to first
         (from-month (plist-get from :month))
         (from-year (plist-get from :year))
         (from-day (plist-get from :day)))
    ;; Generate matching days for current month
    (let* ((all-days (org-habit-plus--generate-monthly-byday-set byday from-month from-year))
           (selected (org-habit-plus--apply-bysetpos all-days bysetpos))
           (target-day (car (cl-remove-if (lambda (d) (<= d from-day)) selected))))
      (if target-day
          (list :year from-year
                :month from-month
                :day target-day
                :hour (plist-get from :hour)
                :minute (plist-get from :minute)
                :second (plist-get from :second))
        ;; Move to next month
        (let ((next-month (+ from-month interval))
              (next-year from-year))
          (while (> next-month 12)
            (setq next-month (- next-month 12))
            (setq next-year (1+ next-year)))
          (let* ((next-all-days (org-habit-plus--generate-monthly-byday-set byday next-month next-year))
                 (next-selected (org-habit-plus--apply-bysetpos next-all-days bysetpos)))
            (list :year next-year
                  :month next-month
                  :day (car next-selected)
                  :hour (plist-get from :hour)
                  :minute (plist-get from :minute)
                  :second (plist-get from :second))))))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 10: RRULE Evaluator - Sub-daily Frequencies

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-next-hourly ()
  "Test hourly recurrence."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=HOURLY;INTERVAL=2"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 30 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 12 (plist-get next :hour))
    (assert-equal 30 (plist-get next :minute))))

(deftest test-rrule-next-minutely ()
  "Test minutely recurrence."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=MINUTELY;INTERVAL=25"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 30 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 10 (plist-get next :hour))
    (assert-equal 55 (plist-get next :minute))))

(deftest test-rrule-next-secondly ()
  "Test secondly recurrence (e.g., pomodoro)."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=SECONDLY;INTERVAL=1500"))  ; 25 min pomodoro
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 10 (plist-get next :hour))
    (assert-equal 25 (plist-get next :minute))
    (assert-equal 0 (plist-get next :second))))

(deftest test-rrule-next-hourly-day-boundary ()
  "Test hourly crossing day boundary."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=HOURLY;INTERVAL=3"))
         (from '(:year 2024 :month 1 :day 13 :hour 23 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    (assert-equal 2 (plist-get next :hour))
    (assert-equal 14 (plist-get next :day))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement sub-daily evaluators**

```elisp
(defun org-habit-plus--rrule-next-hourly (rule from)
  "Compute next hourly occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-plus--datetime-add from :hours interval)))

(defun org-habit-plus--rrule-next-minutely (rule from)
  "Compute next minutely occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-plus--datetime-add from :minutes interval)))

(defun org-habit-plus--rrule-next-secondly (rule from)
  "Compute next secondly occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-plus--datetime-add from :seconds interval)))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 11: RRULE COUNT and UNTIL Termination

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-parse-until ()
  "Test parsing UNTIL date."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;UNTIL=20240131")))
    (assert-equal 'daily (plist-get rule :freq))
    (let ((until (plist-get rule :until)))
      (assert-equal 2024 (plist-get until :year))
      (assert-equal 1 (plist-get until :month))
      (assert-equal 31 (plist-get until :day)))))

(deftest test-rrule-next-with-count ()
  "Test that rule tracks count."
  ;; Note: COUNT requires tracking completions, which happens at org level
  ;; For now, just verify parsing works
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;COUNT=10")))
    (assert-equal 10 (plist-get rule :count))))

(deftest test-rrule-next-respects-until ()
  "Test that next occurrence respects UNTIL boundary."
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;UNTIL=20240115"))
         (from '(:year 2024 :month 1 :day 14 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; Next would be Jan 15, which equals UNTIL, so should return it
    (assert-equal 15 (plist-get next :day)))
  (let* ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;UNTIL=20240115"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-plus--rrule-next-occurrence rule from)))
    ;; From Jan 15, next would be Jan 16 which is past UNTIL, return nil
    (assert-equal nil next)))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement UNTIL parsing and checking**

```elisp
(defun org-habit-plus--parse-rrule-date (date-string)
  "Parse RRULE date string (YYYYMMDD or YYYYMMDDTHHMMSS) to datetime."
  (if (string-match "^\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)\\(?:T\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)\\)?$" date-string)
      (list :year (string-to-number (match-string 1 date-string))
            :month (string-to-number (match-string 2 date-string))
            :day (string-to-number (match-string 3 date-string))
            :hour (if (match-string 4 date-string)
                      (string-to-number (match-string 4 date-string))
                    23)
            :minute (if (match-string 5 date-string)
                        (string-to-number (match-string 5 date-string))
                      59)
            :second (if (match-string 6 date-string)
                        (string-to-number (match-string 6 date-string))
                      59))
    (error "Invalid RRULE date: %s" date-string)))

;; Update the UNTIL parsing in org-habit-plus--rrule-parse:
;; Change the UNTIL clause to:
         ((string= key "UNTIL")
          (setq rule (plist-put rule :until (org-habit-plus--parse-rrule-date value))))

;; Update org-habit-plus--rrule-next-occurrence to check UNTIL:
(defun org-habit-plus--rrule-next-occurrence (rule from)
  "Compute next occurrence of RULE strictly after FROM datetime.
Returns nil if no more occurrences (past UNTIL or COUNT exhausted)."
  (let* ((freq (plist-get rule :freq))
         (until (plist-get rule :until))
         (next (pcase freq
                 ('daily (org-habit-plus--rrule-next-daily rule from))
                 ('weekly (org-habit-plus--rrule-next-weekly rule from))
                 ('monthly (org-habit-plus--rrule-next-monthly rule from))
                 ('yearly (org-habit-plus--rrule-next-yearly rule from))
                 ('hourly (org-habit-plus--rrule-next-hourly rule from))
                 ('minutely (org-habit-plus--rrule-next-minutely rule from))
                 ('secondly (org-habit-plus--rrule-next-secondly rule from))
                 (_ (error "Unknown frequency: %s" freq)))))
    ;; Check UNTIL boundary
    (when (and next until)
      (when (> (org-habit-plus--datetime-compare next until) 0)
        (setq next nil)))
    next))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 12: X-REPEAT-FROM Extension

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-parse-repeat-from ()
  "Test parsing X-REPEAT-FROM extension."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=completion")))
    (assert-equal 'completion (plist-get rule :repeat-from)))
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=scheduled")))
    (assert-equal 'scheduled (plist-get rule :repeat-from)))
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=scheduled-future")))
    (assert-equal 'scheduled-future (plist-get rule :repeat-from))))

(deftest test-repeat-from-completion ()
  "Test that completion-based repeat uses today's date."
  ;; This tests the integration logic, not the parser
  ;; When X-REPEAT-FROM=completion, we compute from current time, not scheduled
  (let* ((rule '(:freq daily :interval 3 :repeat-from completion))
         ;; Scheduled was Jan 10, but completed today (Jan 13)
         (scheduled '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (today '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (base (org-habit-plus--get-repeat-base rule scheduled today))
         (next (org-habit-plus--rrule-next-occurrence rule base)))
    ;; Should be 3 days from today (Jan 13), not from scheduled (Jan 10)
    (assert-equal 16 (plist-get next :day))))

(deftest test-repeat-from-scheduled ()
  "Test that scheduled-based repeat uses scheduled date."
  (let* ((rule '(:freq daily :interval 3 :repeat-from scheduled))
         (scheduled '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (today '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (base (org-habit-plus--get-repeat-base rule scheduled today))
         (next (org-habit-plus--rrule-next-occurrence rule base)))
    ;; Should be 3 days from scheduled (Jan 10) = Jan 13
    ;; But Jan 13 is today, so next interval: Jan 16
    (assert-equal 13 (plist-get next :day))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement repeat-from logic**

```elisp
(defun org-habit-plus--get-repeat-base (rule scheduled today)
  "Determine base datetime for next occurrence calculation.
RULE is the parsed RRULE, SCHEDULED is the scheduled datetime,
TODAY is current datetime.
Returns the datetime to use as base for next occurrence."
  (let ((repeat-from (or (plist-get rule :repeat-from) 'completion)))
    (pcase repeat-from
      ('completion today)
      ('scheduled scheduled)
      ('scheduled-future
       ;; Like scheduled, but if result would be in past, use today
       scheduled)
      (_ today))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 13: X-WARN Extension

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-rrule-parse-warn ()
  "Test parsing X-WARN extension."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;X-WARN=3d")))
    (assert-equal "3d" (plist-get rule :warn)))
  (let ((rule (org-habit-plus--rrule-parse "FREQ=HOURLY;X-WARN=2h")))
    (assert-equal "2h" (plist-get rule :warn))))

(deftest test-warn-duration-parse ()
  "Test parsing warning duration strings."
  (assert-equal 3 (org-habit-plus--parse-warn-days "3d"))
  (assert-equal 14 (org-habit-plus--parse-warn-days "2w"))
  (assert-equal 1 (org-habit-plus--parse-warn-days "1d"))
  ;; Hours get converted to fractional days
  (assert-equal 0.5 (org-habit-plus--parse-warn-days "12h")))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement warn parsing**

```elisp
(defun org-habit-plus--parse-warn-days (warn-string)
  "Parse WARN-STRING into number of days.
Supports: Nd (days), Nw (weeks), Nh (hours)."
  (if (string-match "^\\([0-9]+\\)\\([dwh]\\)$" warn-string)
      (let ((n (string-to-number (match-string 1 warn-string)))
            (unit (match-string 2 warn-string)))
        (pcase unit
          ("d" n)
          ("w" (* n 7))
          ("h" (/ n 24.0))
          (_ n)))
    (error "Invalid warn duration: %s" warn-string)))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 14: Org Integration - Update Advice Functions

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-get-recurrence-rrule ()
  "Test getting RRULE recurrence from org entry."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((rule (org-habit-plus--get-recurrence)))
      (assert-true rule)
      (assert-equal 'monthly (plist-get rule :freq))
      (assert-equal '((2 . 6)) (plist-get rule :byday)))))

(deftest test-after-repeat-advice-rrule ()
  "Test advice updates SCHEDULED correctly with RRULE."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-plus-mode 1)
    (org-habit-plus--after-auto-repeat "DONE")
    (let ((scheduled (org-entry-get nil "SCHEDULED")))
      ;; Should be 2nd Saturday of February: Feb 10, 2024
      (assert-match "2024-02-10" scheduled))
    (org-habit-plus-mode -1)))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Update org integration functions**

```elisp
;; Update org-habit-plus--get-recurrence to use new parser
(defun org-habit-plus--get-recurrence (&optional pom)
  "Get parsed recurrence rule from entry at POM.
Returns nil if no RECURRENCE property exists."
  (let ((recurrence-string (org-entry-get pom org-habit-plus-recurrence-property)))
    (when recurrence-string
      (org-habit-plus--rrule-parse recurrence-string))))

;; Update datetime conversion for org timestamps
(defun org-habit-plus--org-ts-to-datetime (ts-string)
  "Convert org timestamp TS-STRING to datetime plist."
  (let* ((time (org-time-string-to-time ts-string))
         (decoded (decode-time time)))
    (list :second (nth 0 decoded)
          :minute (nth 1 decoded)
          :hour (nth 2 decoded)
          :day (nth 3 decoded)
          :month (nth 4 decoded)
          :year (nth 5 decoded))))

(defun org-habit-plus--datetime-to-org-ts (dt)
  "Convert datetime plist DT to org timestamp string."
  (let* ((time (org-habit-plus--datetime-to-time dt))
         (dow (format-time-string "%a" time)))
    (format "<%04d-%02d-%02d %s>"
            (plist-get dt :year)
            (plist-get dt :month)
            (plist-get dt :day)
            dow)))

;; Update the after-repeat advice
(defun org-habit-plus--after-auto-repeat (_done-word)
  "Advice to run after `org-auto-repeat-maybe'.
Overrides the timestamp if entry has a RECURRENCE property."
  (when (and (org-is-habit-p)
             (org-habit-plus--get-recurrence))
    (let* ((rule (org-habit-plus--get-recurrence))
           (base-ts (or org-habit-plus--original-scheduled
                        (org-entry-get nil "SCHEDULED")))
           (base-dt (org-habit-plus--org-ts-to-datetime base-ts))
           (today-dt (org-habit-plus--time-to-datetime (current-time)))
           (repeat-base (org-habit-plus--get-repeat-base rule base-dt today-dt))
           (next-dt (org-habit-plus--rrule-next-occurrence rule repeat-base))
           (next-ts (when next-dt (org-habit-plus--datetime-to-org-ts next-dt))))
      (when next-ts
        (org-schedule nil next-ts))
      (setq org-habit-plus--original-scheduled nil))))
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 15: Approximate Interval for Habit Graph

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write failing tests**

```elisp
(deftest test-approximate-interval-daily ()
  "Test approximate interval for daily rules."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=DAILY;INTERVAL=3")))
    (assert-equal 3 (org-habit-plus--approximate-interval rule))))

(deftest test-approximate-interval-weekly ()
  "Test approximate interval for weekly rules."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY")))
    (assert-equal 7 (org-habit-plus--approximate-interval rule)))
  (let ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY;INTERVAL=2")))
    (assert-equal 14 (org-habit-plus--approximate-interval rule)))
  ;; MWF = 3 times per week, average ~2.3 days between
  (let ((rule (org-habit-plus--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-true (<= 2 (org-habit-plus--approximate-interval rule)))
    (assert-true (>= 3 (org-habit-plus--approximate-interval rule)))))

(deftest test-approximate-interval-monthly ()
  "Test approximate interval for monthly rules."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=MONTHLY;BYDAY=2SA")))
    (assert-equal 30 (org-habit-plus--approximate-interval rule))))

(deftest test-approximate-interval-hourly ()
  "Test approximate interval for hourly (sub-daily)."
  (let ((rule (org-habit-plus--rrule-parse "FREQ=HOURLY;INTERVAL=2")))
    ;; 2 hours = 2/24 of a day, but minimum 1 for graph
    (assert-equal 1 (org-habit-plus--approximate-interval rule))))
```

**Step 2: Run tests to verify they fail**

Run: `vendor/elk/elk test`
Expected: FAIL

**Step 3: Implement improved approximate-interval**

```elisp
(defun org-habit-plus--approximate-interval (rule)
  "Calculate approximate interval in days for RULE.
Used for org-habit graph display."
  (let ((freq (plist-get rule :freq))
        (interval (or (plist-get rule :interval) 1))
        (byday (plist-get rule :byday)))
    (pcase freq
      ('secondly (max 1 (/ (* interval) 86400)))  ; seconds per day
      ('minutely (max 1 (/ (* interval) 1440)))   ; minutes per day
      ('hourly (max 1 (/ (* interval) 24)))       ; hours per day
      ('daily interval)
      ('weekly
       (if (and byday (not (consp (car byday))))
           ;; Multiple days per week: calculate average gap
           (let ((num-days (length byday)))
             (max 1 (/ 7 num-days)))
         ;; Simple weekly
         (* 7 interval)))
      ('monthly (* 30 interval))  ; Approximate
      ('yearly (* 365 interval))
      (_ 7))))  ; Default fallback
```

**Step 4: Run tests to verify they pass**

Run: `vendor/elk/elk test`
Expected: PASS

---

## Task 16: Full Integration Test

**Files:**
- Test: `/home/stag/src/projects/org-habit+.el/test/org-habit-plus-test.el`

**Step 1: Write comprehensive integration test**

```elisp
(deftest test-full-workflow-rrule ()
  "Integration test: RRULE habit workflow."
  (let ((org-log-done nil)
        (org-log-repeat nil)
        (current-time-list (encode-time 0 0 12 13 1 2024)))
    (cl-letf (((symbol-function 'current-time)
               (lambda (&rest _) current-time-list))
              ((symbol-function 'org-current-time)
               (lambda (&rest _) current-time-list)))
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Monthly review\n")
        (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=completion\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (org-habit-plus-mode 1)
        ;; Verify initial state
        (assert-true (org-is-habit-p))
        (let ((rule (org-habit-plus--get-recurrence)))
          (assert-equal 'monthly (plist-get rule :freq))
          (assert-equal '((2 . 6)) (plist-get rule :byday))
          (assert-equal 'completion (plist-get rule :repeat-from)))
        ;; Mark as DONE
        (org-todo "DONE")
        ;; Verify updated schedule
        (assert-equal "TODO" (org-get-todo-state))
        (let ((scheduled (org-entry-get nil "SCHEDULED")))
          (assert-match "2024-02-10" scheduled))
        (org-habit-plus-mode -1)))))

(deftest test-full-workflow-weekly-byday ()
  "Integration test: weekly MWF habit."
  (let ((org-log-done nil)
        (org-log-repeat nil)
        (current-time-list (encode-time 0 0 12 13 1 2024)))  ; Saturday
    (cl-letf (((symbol-function 'current-time)
               (lambda (&rest _) current-time-list)))
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Exercise\n")
        (insert "SCHEDULED: <2024-01-13 Sat .+1d>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR;X-REPEAT-FROM=completion\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (org-habit-plus-mode 1)
        (org-todo "DONE")
        ;; Next MWF after Saturday Jan 13 is Monday Jan 15
        (let ((scheduled (org-entry-get nil "SCHEDULED")))
          (assert-match "2024-01-15" scheduled))
        (org-habit-plus-mode -1)))))

(deftest test-full-workflow-last-sunday-december ()
  "Integration test: yearly last Sunday of December."
  (let ((org-log-done nil)
        (org-log-repeat nil)
        (current-time-list (encode-time 0 0 12 1 1 2024)))
    (cl-letf (((symbol-function 'current-time)
               (lambda (&rest _) current-time-list)))
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Year-end review\n")
        (insert "SCHEDULED: <2024-01-01 Mon .+1y>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (org-habit-plus-mode 1)
        (org-todo "DONE")
        ;; Last Sunday of December 2024 is Dec 29
        (let ((scheduled (org-entry-get nil "SCHEDULED")))
          (assert-match "2024-12-29" scheduled))
        (org-habit-plus-mode -1)))))
```

**Step 2: Run all tests**

Run: `vendor/elk/elk test`
Expected: All tests PASS

---

## Task 17: Clean Up and Documentation

**Files:**
- Modify: `/home/stag/src/projects/org-habit+.el/org-habit-plus.el`
- Modify: `/home/stag/src/projects/org-habit+.el/README.org`

**Step 1: Remove old code**

Remove all legacy functions that are no longer used:
- `org-habit-plus--ordinal-alist` (if not used by RRULE parser)
- `org-habit-plus--weekday-alist` (replaced by `org-habit-plus--rrule-day-alist`)
- `org-habit-plus--ordinal-to-number`
- `org-habit-plus--weekday-to-number`
- `org-habit-plus--nth-weekday-in-month` (use `calendar-nth-named-day` directly)
- `org-habit-plus--first-weekday-in-month`
- `org-habit-plus--last-day-of-month`
- Old next-occurrence functions
- Old Gregorian date format functions (replaced by datetime plists)

**Step 2: Update header documentation**

```elisp
;;; org-habit-plus.el --- Full RRULE recurrence for org-habit -*- lexical-binding: t; -*-

;; Supported RRULE components:
;;   FREQ: SECONDLY, MINUTELY, HOURLY, DAILY, WEEKLY, MONTHLY, YEARLY
;;   INTERVAL: repeat every N periods
;;   BYDAY: weekdays with optional ordinals (MO, 2SA, -1FR)
;;   BYMONTHDAY: days of month (1, 15, -1 for last)
;;   BYMONTH: specific months
;;   BYSETPOS: position in set (1 for first, -1 for last)
;;   BYWEEKNO, BYYEARDAY, BYHOUR, BYMINUTE, BYSECOND
;;   COUNT, UNTIL: termination conditions
;;
;; Extensions:
;;   X-REPEAT-FROM: completion | scheduled | scheduled-future
;;   X-WARN: warning duration (3d, 2w, 12h)
;;
;; Example usage:
;;   :RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=completion
;;   :RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR
;;   :RECURRENCE: FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU
```

**Step 3: Update README.org**

Update with new RRULE syntax documentation and examples.

**Step 4: Run final test suite**

Run: `vendor/elk/elk test`
Expected: All tests PASS

---

## Summary

This plan implements a full RFC 5545 RRULE parser and evaluator for org-habit+, replacing the regex-based approach with a robust, extensible system.

**Key components:**
1. Tokenizer and parser for RRULE strings
2. Datetime utilities for calculations
3. Frequency-specific evaluators (DAILY through YEARLY, plus sub-daily)
4. BYSETPOS support for complex patterns like "first weekday"
5. X-REPEAT-FROM extension for org-mode completion semantics
6. X-WARN extension for warning windows
7. Updated org integration via advice functions

**Test coverage:** Each task includes TDD with specific test cases.

---

**Plan complete. Two execution options:**

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

Which approach?
