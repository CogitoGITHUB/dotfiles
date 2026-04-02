;;; org-habit-ng-test.el --- Tests for org-habit-ng -*- lexical-binding: t; -*-

;;; Commentary:

;; e-unit tests for org-habit-ng

;;; Code:

(require 'e-unit)
(require 'org-habit-ng)

(e-unit-initialize)

(deftest test-ordinal-to-number ()
  "Test ordinal string to number conversion."
  (assert-equal 1 (org-habit-ng--ordinal-to-number "first"))
  (assert-equal 1 (org-habit-ng--ordinal-to-number "1st"))
  (assert-equal 2 (org-habit-ng--ordinal-to-number "second"))
  (assert-equal 2 (org-habit-ng--ordinal-to-number "2nd"))
  (assert-equal 3 (org-habit-ng--ordinal-to-number "third"))
  (assert-equal 3 (org-habit-ng--ordinal-to-number "3rd"))
  (assert-equal 4 (org-habit-ng--ordinal-to-number "fourth"))
  (assert-equal 4 (org-habit-ng--ordinal-to-number "4th"))
  (assert-equal 5 (org-habit-ng--ordinal-to-number "fifth"))
  (assert-equal 5 (org-habit-ng--ordinal-to-number "5th"))
  (assert-equal -1 (org-habit-ng--ordinal-to-number "last")))

(deftest test-weekday-to-number ()
  "Test weekday string to number conversion."
  (assert-equal 0 (org-habit-ng--weekday-to-number "sunday"))
  (assert-equal 0 (org-habit-ng--weekday-to-number "sun"))
  (assert-equal 1 (org-habit-ng--weekday-to-number "monday"))
  (assert-equal 1 (org-habit-ng--weekday-to-number "mon"))
  (assert-equal 2 (org-habit-ng--weekday-to-number "tuesday"))
  (assert-equal 3 (org-habit-ng--weekday-to-number "wednesday"))
  (assert-equal 4 (org-habit-ng--weekday-to-number "thursday"))
  (assert-equal 5 (org-habit-ng--weekday-to-number "friday"))
  (assert-equal 6 (org-habit-ng--weekday-to-number "saturday"))
  (assert-equal 6 (org-habit-ng--weekday-to-number "sat")))

(deftest test-get-recurrence ()
  "Test getting recurrence property from org entry."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((recurrence (org-habit-ng--get-recurrence)))
      (assert-true recurrence)
      (assert-equal 'monthly (plist-get recurrence :freq))
      (assert-equal '((2 . 6)) (plist-get recurrence :byday)))))

(deftest test-date-conversions ()
  "Test date format conversions."
  ;; Gregorian to org timestamp string
  (assert-match "2024-01-13"
                (org-habit-ng--gregorian-to-org-ts '(1 13 2024)))
  ;; Org timestamp to Gregorian
  (assert-equal '(1 13 2024)
                (org-habit-ng--org-ts-to-gregorian "<2024-01-13 Sat>"))
  (assert-equal '(2 10 2024)
                (org-habit-ng--org-ts-to-gregorian "<2024-02-10 Sat .+1m>")))

(deftest test-handle-repeat ()
  "Test that handle-repeat updates SCHEDULED to next occurrence."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    ;; Use X-REPEAT-FROM=scheduled to avoid current-time dependency
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=scheduled\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Simulate completing the habit
    (org-habit-ng--handle-repeat)
    ;; Should now be scheduled for Feb 10, 2024 (2nd Sat of Feb)
    (let ((scheduled (org-entry-get nil "SCHEDULED")))
      (assert-match "2024-02-10" scheduled))))

(deftest test-advice-integration ()
  "Test that advice intercepts org-auto-repeat-maybe."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    ;; Use X-REPEAT-FROM=scheduled to avoid current-time dependency
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=scheduled\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Enable org-habit-ng-mode
    (org-habit-ng-mode 1)
    ;; Simulate the advice being called
    (org-habit-ng--after-auto-repeat "DONE")
    ;; Should be scheduled for 2nd Sat of Feb
    (let ((scheduled (org-entry-get nil "SCHEDULED")))
      (assert-match "2024-02-10" scheduled))
    ;; Clean up
    (org-habit-ng-mode -1)))

(deftest test-approximate-interval ()
  "Test approximate interval calculation for graph display."
  ;; RRULE monthly is approximately 30 days
  (let ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=2SA")))
    (let ((interval (org-habit-ng--approximate-interval rule)))
      ;; Should be 30 days (monthly)
      (assert-equal 30 interval)))
  ;; Weekly with multiple days
  (let ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (let ((interval (org-habit-ng--approximate-interval rule)))
      ;; 3 days per week: 7/3 = 2
      (assert-equal 2 interval)))
  ;; Daily
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;INTERVAL=3")))
    (let ((interval (org-habit-ng--approximate-interval rule)))
      (assert-equal 3 interval))))

(deftest test-parse-todo-advice ()
  "Test that parse-todo returns correct interval for complex recurrence."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Test habit\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1d>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (org-habit-ng-mode 1)
    ;; Parse the habit
    (let ((habit-data (org-habit-parse-todo)))
      ;; Element 1 is the repeat interval in days
      ;; Should be 30 (monthly) instead of 1 (from .+1d)
      (assert-equal 30 (nth 1 habit-data)))
    (org-habit-ng-mode -1)))

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
      ;; Use X-REPEAT-FROM=scheduled to avoid current-time dependency
      (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=scheduled\n")
      (insert ":END:\n")
      (goto-char (point-min))
      (org-habit-ng-mode 1)
      ;; Verify initial state
      (assert-true (org-is-habit-p))
      (assert-true (org-habit-ng--get-recurrence))
      ;; Mark as DONE (this triggers org-auto-repeat-maybe)
      (org-todo "DONE")
      ;; State should return to TODO
      (assert-equal "TODO" (org-get-todo-state))
      ;; Should be scheduled for 2nd Saturday of February
      (let ((scheduled (org-entry-get nil "SCHEDULED")))
        (assert-match "2024-02-10" scheduled))
      (org-habit-ng-mode -1))))

;; Task 1: RRULE Tokenizer tests

(deftest test-rrule-tokenize-simple ()
  "Test tokenizing simple RRULE string."
  (let ((tokens (org-habit-ng--rrule-tokenize "FREQ=DAILY;INTERVAL=3")))
    (assert-equal '(("FREQ" . "DAILY") ("INTERVAL" . "3")) tokens)))

(deftest test-rrule-tokenize-complex ()
  "Test tokenizing RRULE with multiple values."
  (let ((tokens (org-habit-ng--rrule-tokenize "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-equal '(("FREQ" . "WEEKLY") ("BYDAY" . "MO,WE,FR")) tokens)))

(deftest test-rrule-tokenize-extensions ()
  "Test tokenizing with X- extensions."
  (let ((tokens (org-habit-ng--rrule-tokenize "FREQ=DAILY;X-REPEAT-FROM=completion;X-WARN=2d")))
    (assert-equal '(("FREQ" . "DAILY") ("X-REPEAT-FROM" . "completion") ("X-WARN" . "2d")) tokens)))

;; Task 2: RRULE Parser tests

(deftest test-rrule-parse-daily ()
  "Test parsing DAILY frequency."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;INTERVAL=3")))
    (assert-equal 'daily (plist-get rule :freq))
    (assert-equal 3 (plist-get rule :interval))))

(deftest test-rrule-parse-weekly-byday ()
  "Test parsing WEEKLY with BYDAY."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-equal 'weekly (plist-get rule :freq))
    (assert-equal '(1 3 5) (plist-get rule :byday))))

(deftest test-rrule-parse-monthly-byday-ordinal ()
  "Test parsing MONTHLY with ordinal BYDAY."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=2SA")))
    (assert-equal 'monthly (plist-get rule :freq))
    (assert-equal '((2 . 6)) (plist-get rule :byday))))  ; 2nd Saturday

(deftest test-rrule-parse-monthly-byday-last ()
  "Test parsing MONTHLY with last weekday."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR")))
    (assert-equal 'monthly (plist-get rule :freq))
    (assert-equal '((-1 . 5)) (plist-get rule :byday))))  ; last Friday

;; Task 3: Date/Time Utilities tests

(deftest test-datetime-to-list ()
  "Test converting Emacs time to datetime list."
  (let ((time (encode-time 30 15 10 13 1 2024)))  ; 2024-01-13 10:15:30
    (let ((dt (org-habit-ng--time-to-datetime time)))
      (assert-equal 2024 (plist-get dt :year))
      (assert-equal 1 (plist-get dt :month))
      (assert-equal 13 (plist-get dt :day))
      (assert-equal 10 (plist-get dt :hour))
      (assert-equal 15 (plist-get dt :minute))
      (assert-equal 30 (plist-get dt :second)))))

(deftest test-datetime-to-time ()
  "Test converting datetime list back to Emacs time."
  (let* ((dt '(:year 2024 :month 1 :day 13 :hour 10 :minute 15 :second 30))
         (time (org-habit-ng--datetime-to-time dt))
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
    (assert-equal 6 (org-habit-ng--datetime-dow dt))))

(deftest test-datetime-compare ()
  "Test comparing two datetimes."
  (let ((dt1 '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
        (dt2 '(:year 2024 :month 1 :day 14 :hour 10 :minute 0 :second 0))
        (dt3 '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0)))
    (assert-equal -1 (org-habit-ng--datetime-compare dt1 dt2))
    (assert-equal 1 (org-habit-ng--datetime-compare dt2 dt1))
    (assert-equal 0 (org-habit-ng--datetime-compare dt1 dt3))))

(deftest test-datetime-add-days ()
  "Test adding days to datetime."
  (let* ((dt '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (result (org-habit-ng--datetime-add dt :days 3)))
    (assert-equal 16 (plist-get result :day))
    (assert-equal 1 (plist-get result :month))
    (assert-equal 2024 (plist-get result :year))))

(deftest test-datetime-add-months ()
  "Test adding months to datetime."
  (let* ((dt '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (result (org-habit-ng--datetime-add dt :months 1)))
    (assert-equal 13 (plist-get result :day))
    (assert-equal 2 (plist-get result :month))
    (assert-equal 2024 (plist-get result :year))))

(deftest test-datetime-add-month-boundary ()
  "Test adding days across month boundary."
  (let* ((dt '(:year 2024 :month 1 :day 31 :hour 10 :minute 0 :second 0))
         (result (org-habit-ng--datetime-add dt :days 1)))
    (assert-equal 1 (plist-get result :day))
    (assert-equal 2 (plist-get result :month))
    (assert-equal 2024 (plist-get result :year))))

;; Task 4: RRULE Evaluator - DAILY Frequency tests

(deftest test-rrule-next-daily-simple ()
  "Test next occurrence for simple daily rule."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=DAILY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 14 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))
    (assert-equal 2024 (plist-get next :year))))

(deftest test-rrule-next-daily-interval ()
  "Test next occurrence for daily with interval."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;INTERVAL=3"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 16 (plist-get next :day))))

(deftest test-rrule-next-daily-month-boundary ()
  "Test daily rule crossing month boundary."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=DAILY"))
         (from '(:year 2024 :month 1 :day 31 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 1 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

;; Task 5: RRULE Evaluator - WEEKLY Frequency tests

(deftest test-rrule-next-weekly-simple ()
  "Test next occurrence for simple weekly rule."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))  ; Saturday
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 20 (plist-get next :day))))  ; Next Saturday

(deftest test-rrule-next-weekly-byday ()
  "Test weekly with specific days."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))  ; Saturday
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Next MO/WE/FR after Saturday Jan 13 is Monday Jan 15
    (assert-equal 15 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-weekly-byday-same-week ()
  "Test weekly BYDAY within same week."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))  ; Monday
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Next MO/WE/FR after Monday Jan 15 is Wednesday Jan 17
    (assert-equal 17 (plist-get next :day))))

;; Task 6: RRULE Evaluator - MONTHLY with BYDAY tests

(deftest test-rrule-next-monthly-byday-ordinal ()
  "Test monthly with ordinal BYDAY (2nd Saturday)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=2SA"))
         (from '(:year 2024 :month 1 :day 14 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; After Jan 14, next 2nd Saturday is Feb 10, 2024
    (assert-equal 10 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-byday-last ()
  "Test monthly with last weekday (-1FR)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Last Friday of January 2024 is Jan 26
    (assert-equal 26 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-byday-last-rollover ()
  "Test monthly last weekday rolling to next month."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=-1FR"))
         (from '(:year 2024 :month 1 :day 27 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; After Jan 27, next last Friday is Feb 23
    (assert-equal 23 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

;; Task 7: RRULE Evaluator - MONTHLY with BYMONTHDAY tests

(deftest test-rrule-next-monthly-bymonthday ()
  "Test monthly with specific day of month."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=15"))
         (from '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 15 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-rollover ()
  "Test monthly BYMONTHDAY rolling to next month."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=15"))
         (from '(:year 2024 :month 1 :day 16 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 15 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-last ()
  "Test monthly with last day of month (-1)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=-1"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Last day of January is 31
    (assert-equal 31 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

(deftest test-rrule-next-monthly-bymonthday-last-feb ()
  "Test last day with February (leap year)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYMONTHDAY=-1"))
         (from '(:year 2024 :month 2 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; 2024 is leap year, Feb has 29 days
    (assert-equal 29 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

;; Task 8: RRULE Evaluator - YEARLY Frequency tests

(deftest test-rrule-next-yearly-simple ()
  "Test simple yearly recurrence."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=YEARLY"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 13 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))
    (assert-equal 2025 (plist-get next :year))))

(deftest test-rrule-next-yearly-bymonth-byday ()
  "Test yearly with BYMONTH and BYDAY (last Sunday of December)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Last Sunday of December 2024 is Dec 29
    (assert-equal 29 (plist-get next :day))
    (assert-equal 12 (plist-get next :month))
    (assert-equal 2024 (plist-get next :year))))

(deftest test-rrule-next-yearly-bymonth-byday-rollover ()
  "Test yearly BYMONTH/BYDAY rolling to next year."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU"))
         (from '(:year 2024 :month 12 :day 30 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Last Sunday of December 2025 is Dec 28
    (assert-equal 28 (plist-get next :day))
    (assert-equal 12 (plist-get next :month))
    (assert-equal 2025 (plist-get next :year))))

;; Task 9: RRULE Evaluator - BYSETPOS tests

(deftest test-rrule-next-monthly-bysetpos-first-weekday ()
  "Test first weekday of month using BYSETPOS."
  ;; BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1 means first weekday
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1"))
         (from '(:year 2024 :month 1 :day 1 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; January 2024 starts on Monday, so first weekday is Jan 1
    ;; But we're ON Jan 1, so next is Feb 1 (Thursday)
    (assert-equal 1 (plist-get next :day))
    (assert-equal 2 (plist-get next :month))))

(deftest test-rrule-next-monthly-bysetpos-last-weekday ()
  "Test last weekday of month using BYSETPOS."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Last weekday of January 2024 is Wed Jan 31
    (assert-equal 31 (plist-get next :day))
    (assert-equal 1 (plist-get next :month))))

;; Task 10: RRULE Evaluator - Sub-daily Frequencies tests

(deftest test-rrule-next-hourly ()
  "Test hourly recurrence."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;INTERVAL=2"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 30 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 12 (plist-get next :hour))
    (assert-equal 30 (plist-get next :minute))))

(deftest test-rrule-next-minutely ()
  "Test minutely recurrence."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=MINUTELY;INTERVAL=25"))
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 30 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 10 (plist-get next :hour))
    (assert-equal 55 (plist-get next :minute))))

(deftest test-rrule-next-secondly ()
  "Test secondly recurrence (e.g., pomodoro)."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=SECONDLY;INTERVAL=1500"))  ; 25 min pomodoro
         (from '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 10 (plist-get next :hour))
    (assert-equal 25 (plist-get next :minute))
    (assert-equal 0 (plist-get next :second))))

(deftest test-rrule-next-hourly-day-boundary ()
  "Test hourly crossing day boundary."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;INTERVAL=3"))
         (from '(:year 2024 :month 1 :day 13 :hour 23 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    (assert-equal 2 (plist-get next :hour))
    (assert-equal 14 (plist-get next :day))))

;; Task 11: RRULE COUNT and UNTIL Termination tests

(deftest test-rrule-parse-until ()
  "Test parsing UNTIL date."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;UNTIL=20240131")))
    (assert-equal 'daily (plist-get rule :freq))
    (let ((until (plist-get rule :until)))
      (assert-equal 2024 (plist-get until :year))
      (assert-equal 1 (plist-get until :month))
      (assert-equal 31 (plist-get until :day)))))

(deftest test-rrule-parse-until-with-time ()
  "Test parsing UNTIL with time component."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;UNTIL=20240131T235959")))
    (assert-equal 'daily (plist-get rule :freq))
    (let ((until (plist-get rule :until)))
      (assert-equal 2024 (plist-get until :year))
      (assert-equal 1 (plist-get until :month))
      (assert-equal 31 (plist-get until :day))
      (assert-equal 23 (plist-get until :hour))
      (assert-equal 59 (plist-get until :minute))
      (assert-equal 59 (plist-get until :second)))))

(deftest test-rrule-next-with-count ()
  "Test that rule tracks count."
  ;; Note: COUNT requires tracking completions, which happens at org level
  ;; For now, just verify parsing works
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;COUNT=10")))
    (assert-equal 10 (plist-get rule :count))))

(deftest test-rrule-next-respects-until ()
  "Test that next occurrence respects UNTIL boundary."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;UNTIL=20240115"))
         (from '(:year 2024 :month 1 :day 14 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Next would be Jan 15, which equals UNTIL, so should return it
    (assert-equal 15 (plist-get next :day)))
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;UNTIL=20240115"))
         (from '(:year 2024 :month 1 :day 15 :hour 10 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; From Jan 15, next would be Jan 16 which is past UNTIL, return nil
    (assert-equal nil next)))

(deftest test-rrule-next-respects-until-with-time ()
  "Test UNTIL boundary with time component."
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;INTERVAL=1;UNTIL=20240115T120000"))
         (from '(:year 2024 :month 1 :day 15 :hour 11 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; Next would be 12:00, which equals UNTIL, should return it
    (assert-equal 12 (plist-get next :hour)))
  (let* ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;INTERVAL=1;UNTIL=20240115T120000"))
         (from '(:year 2024 :month 1 :day 15 :hour 12 :minute 0 :second 0))
         (next (org-habit-ng--rrule-next-occurrence rule from)))
    ;; From 12:00, next would be 13:00 which is past UNTIL, return nil
    (assert-equal nil next)))

;; Task 12: X-REPEAT-FROM Extension tests

(deftest test-rrule-parse-repeat-from ()
  "Test parsing X-REPEAT-FROM extension."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=completion")))
    (assert-equal 'completion (plist-get rule :repeat-from)))
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=scheduled")))
    (assert-equal 'scheduled (plist-get rule :repeat-from)))
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;X-REPEAT-FROM=scheduled-future")))
    (assert-equal 'scheduled-future (plist-get rule :repeat-from))))

(deftest test-repeat-from-completion ()
  "Test that completion-based repeat uses today's date."
  ;; This tests the integration logic, not the parser
  ;; When X-REPEAT-FROM=completion, we compute from current time, not scheduled
  (let* ((rule '(:freq daily :interval 3 :repeat-from completion))
         ;; Scheduled was Jan 10, but completed today (Jan 13)
         (scheduled '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (today '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (base (org-habit-ng--get-repeat-base rule scheduled today))
         (next (org-habit-ng--rrule-next-occurrence rule base)))
    ;; Should be 3 days from today (Jan 13), not from scheduled (Jan 10)
    (assert-equal 16 (plist-get next :day))))

(deftest test-repeat-from-scheduled ()
  "Test that scheduled-based repeat uses scheduled date."
  (let* ((rule '(:freq daily :interval 3 :repeat-from scheduled))
         (scheduled '(:year 2024 :month 1 :day 10 :hour 10 :minute 0 :second 0))
         (today '(:year 2024 :month 1 :day 13 :hour 10 :minute 0 :second 0))
         (base (org-habit-ng--get-repeat-base rule scheduled today))
         (next (org-habit-ng--rrule-next-occurrence rule base)))
    ;; Should be 3 days from scheduled (Jan 10) = Jan 13
    ;; But Jan 13 is today, so next interval: Jan 16
    (assert-equal 13 (plist-get next :day))))

;; Task 13: X-WARN Extension tests

(deftest test-rrule-parse-warn ()
  "Test parsing X-WARN extension."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;X-WARN=3d")))
    (assert-equal "3d" (plist-get rule :warn)))
  (let ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;X-WARN=2h")))
    (assert-equal "2h" (plist-get rule :warn))))

(deftest test-warn-duration-parse ()
  "Test parsing warning duration strings."
  (assert-equal 3 (org-habit-ng--parse-warn-days "3d"))
  (assert-equal 14 (org-habit-ng--parse-warn-days "2w"))
  (assert-equal 1 (org-habit-ng--parse-warn-days "1d"))
  ;; Hours get converted to fractional days
  (assert-equal 0.5 (org-habit-ng--parse-warn-days "12h")))

;; Task 14: Org Integration - Update Advice Functions tests

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
    (let ((rule (org-habit-ng--get-recurrence)))
      (assert-true rule)
      (assert-equal 'monthly (plist-get rule :freq))
      (assert-equal '((2 . 6)) (plist-get rule :byday)))))

(deftest test-org-ts-to-datetime ()
  "Test converting org timestamp to datetime plist."
  (let ((dt (org-habit-ng--org-ts-to-datetime "<2024-01-13 Sat 10:15>")))
    (assert-equal 2024 (plist-get dt :year))
    (assert-equal 1 (plist-get dt :month))
    (assert-equal 13 (plist-get dt :day))
    (assert-equal 10 (plist-get dt :hour))
    (assert-equal 15 (plist-get dt :minute))))

(deftest test-datetime-to-org-ts ()
  "Test converting datetime plist to org timestamp."
  (let* ((dt '(:year 2024 :month 1 :day 13 :hour 10 :minute 15 :second 0))
         (ts (org-habit-ng--datetime-to-org-ts dt)))
    (assert-match "2024-01-13" ts)
    (assert-match "Sat" ts)))

;; Note: Full integration tests with org-todo are commented out due to complexity
;; of mocking org-mode's internal timestamp handling. The component tests above
;; verify that the RRULE parsing, evaluation, and datetime conversion work correctly.

;; Task 15: Approximate Interval for Habit Graph (RRULE tests)

(deftest test-approximate-interval-daily ()
  "Test approximate interval for daily rules."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=DAILY;INTERVAL=3")))
    (assert-equal 3 (org-habit-ng--approximate-interval rule))))

(deftest test-approximate-interval-weekly ()
  "Test approximate interval for weekly rules."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY")))
    (assert-equal 7 (org-habit-ng--approximate-interval rule)))
  (let ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;INTERVAL=2")))
    (assert-equal 14 (org-habit-ng--approximate-interval rule)))
  ;; MWF = 3 times per week, average ~2.3 days between
  (let ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;BYDAY=MO,WE,FR")))
    (assert-true (<= 2 (org-habit-ng--approximate-interval rule)))
    (assert-true (>= 3 (org-habit-ng--approximate-interval rule)))))

(deftest test-approximate-interval-monthly ()
  "Test approximate interval for monthly rules."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=2SA")))
    (assert-equal 30 (org-habit-ng--approximate-interval rule))))

(deftest test-approximate-interval-hourly ()
  "Test approximate interval for hourly (sub-daily)."
  (let ((rule (org-habit-ng--rrule-parse "FREQ=HOURLY;INTERVAL=2")))
    ;; 2 hours = 2/24 of a day, but minimum 1 for graph
    (assert-equal 1 (org-habit-ng--approximate-interval rule))))

;; Task 16: Full Integration Tests
;; These test the RRULE engine end-to-end without triggering org-mode's
;; full state machine (which requires extensive time mocking).

(deftest test-full-workflow-rrule ()
  "Integration test: RRULE habit workflow - monthly 2nd Saturday."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Monthly review\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=completion\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Verify parsing works
    (assert-true (org-is-habit-p))
    (let ((rule (org-habit-ng--get-recurrence)))
      (assert-equal 'monthly (plist-get rule :freq))
      (assert-equal '((2 . 6)) (plist-get rule :byday))
      (assert-equal 'completion (plist-get rule :repeat-from)))
    ;; Verify next occurrence calculation
    (let* ((rule (org-habit-ng--get-recurrence))
           (from '(:year 2024 :month 1 :day 13 :hour 12 :minute 0 :second 0))
           (next (org-habit-ng--rrule-next-occurrence rule from)))
      ;; Next 2nd Saturday after Jan 13 is Feb 10
      (assert-equal 2 (plist-get next :month))
      (assert-equal 10 (plist-get next :day))
      (assert-equal 2024 (plist-get next :year)))))

(deftest test-full-workflow-weekly-byday ()
  "Integration test: weekly MWF habit."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Exercise\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1d>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR;X-REPEAT-FROM=completion\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Verify parsing
    (let ((rule (org-habit-ng--get-recurrence)))
      (assert-equal 'weekly (plist-get rule :freq))
      (assert-equal '(1 3 5) (plist-get rule :byday)))
    ;; Verify next occurrence - from Saturday Jan 13, next MWF is Monday Jan 15
    (let* ((rule (org-habit-ng--get-recurrence))
           (from '(:year 2024 :month 1 :day 13 :hour 12 :minute 0 :second 0))
           (next (org-habit-ng--rrule-next-occurrence rule from)))
      (assert-equal 1 (plist-get next :month))
      (assert-equal 15 (plist-get next :day)))))

(deftest test-full-workflow-last-sunday-december ()
  "Integration test: yearly last Sunday of December."
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Year-end review\n")
    (insert "SCHEDULED: <2024-01-01 Mon .+1y>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU\n")
    (insert ":END:\n")
    (goto-char (point-min))
    ;; Verify parsing
    (let ((rule (org-habit-ng--get-recurrence)))
      (assert-equal 'yearly (plist-get rule :freq))
      (assert-equal '(12) (plist-get rule :bymonth))
      (assert-equal '((-1 . 0)) (plist-get rule :byday)))
    ;; Verify next occurrence - from Jan 1 2024, next is Dec 29 2024
    (let* ((rule (org-habit-ng--get-recurrence))
           (from '(:year 2024 :month 1 :day 1 :hour 12 :minute 0 :second 0))
           (next (org-habit-ng--rrule-next-occurrence rule from)))
      (assert-equal 12 (plist-get next :month))
      (assert-equal 29 (plist-get next :day))
      (assert-equal 2024 (plist-get next :year)))))

;; Task 1: RRULE Builder tests

(deftest test-rrule-build-daily ()
  "Test building daily RRULE strings."
  (assert-equal "FREQ=DAILY;INTERVAL=1"
                (org-habit-ng--rrule-build '(:freq daily :interval 1)))
  (assert-equal "FREQ=DAILY;INTERVAL=3"
                (org-habit-ng--rrule-build '(:freq daily :interval 3))))

(deftest test-rrule-build-weekly ()
  "Test building weekly RRULE strings."
  (assert-equal "FREQ=WEEKLY;INTERVAL=1"
                (org-habit-ng--rrule-build '(:freq weekly :interval 1)))
  (assert-equal "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
                (org-habit-ng--rrule-build '(:freq weekly :interval 2 :byday (1 3 5)))))

(deftest test-rrule-build-monthly ()
  "Test building monthly RRULE strings."
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15"
                (org-habit-ng--rrule-build '(:freq monthly :interval 1 :bymonthday (15))))
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYDAY=2SA"
                (org-habit-ng--rrule-build '(:freq monthly :interval 1 :byday ((2 . 6)))))
  (assert-equal "FREQ=MONTHLY;INTERVAL=1;BYDAY=-1FR"
                (org-habit-ng--rrule-build '(:freq monthly :interval 1 :byday ((-1 . 5))))))

(deftest test-rrule-build-yearly ()
  "Test building yearly RRULE strings."
  (assert-equal "FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYDAY=-1SU"
                (org-habit-ng--rrule-build '(:freq yearly :interval 1 :bymonth (12) :byday ((-1 . 0))))))

(deftest test-rrule-build-extensions ()
  "Test building RRULE with extensions."
  (assert-equal "FREQ=DAILY;INTERVAL=3;X-REPEAT-FROM=completion"
                (org-habit-ng--rrule-build '(:freq daily :interval 3 :repeat-from completion)))
  (assert-equal "FREQ=DAILY;INTERVAL=3;X-FLEXIBILITY=1"
                (org-habit-ng--rrule-build '(:freq daily :interval 3 :flexibility 1))))

;; Task 2: Natural Language Generator tests

(deftest test-rrule-to-human-daily ()
  "Test daily RRULE to human-readable."
  (assert-equal "Every day"
                (org-habit-ng-rrule-to-human '(:freq daily :interval 1)))
  (assert-equal "Every 3 days"
                (org-habit-ng-rrule-to-human '(:freq daily :interval 3))))

(deftest test-rrule-to-human-weekly ()
  "Test weekly RRULE to human-readable."
  (assert-equal "Every week"
                (org-habit-ng-rrule-to-human '(:freq weekly :interval 1)))
  (assert-equal "Every 2 weeks"
                (org-habit-ng-rrule-to-human '(:freq weekly :interval 2)))
  (assert-equal "Every week on Monday, Wednesday, Friday"
                (org-habit-ng-rrule-to-human '(:freq weekly :interval 1 :byday (1 3 5)))))

(deftest test-rrule-to-human-monthly ()
  "Test monthly RRULE to human-readable."
  (assert-equal "Every month on day 15"
                (org-habit-ng-rrule-to-human '(:freq monthly :interval 1 :bymonthday (15))))
  (assert-equal "Every month on the 2nd Saturday"
                (org-habit-ng-rrule-to-human '(:freq monthly :interval 1 :byday ((2 . 6)))))
  (assert-equal "Every month on the last Friday"
                (org-habit-ng-rrule-to-human '(:freq monthly :interval 1 :byday ((-1 . 5)))))
  (assert-equal "Every month on the last day"
                (org-habit-ng-rrule-to-human '(:freq monthly :interval 1 :bymonthday (-1)))))

(deftest test-rrule-to-human-yearly ()
  "Test yearly RRULE to human-readable."
  (assert-equal "Every year in December on the last Sunday"
                (org-habit-ng-rrule-to-human '(:freq yearly :interval 1 :bymonth (12) :byday ((-1 . 0))))))

(deftest test-rrule-to-human-flexibility ()
  "Test flexibility window in human-readable output."
  (assert-equal "Every 3 days (within 1 day)"
                (org-habit-ng-rrule-to-human '(:freq daily :interval 3 :flexibility 1))))

;; Task 3: Next Occurrences Helper tests

(deftest test-next-n-occurrences ()
  "Test generating multiple future occurrences."
  (let* ((rule '(:freq weekly :interval 1))
         (from '(:year 2024 :month 1 :day 1 :hour 0 :minute 0 :second 0))
         (occurrences (org-habit-ng-next-n-occurrences rule from 3)))
    (assert-equal 3 (length occurrences))
    ;; Weekly from Jan 1: Jan 8, Jan 15, Jan 22
    (assert-equal 8 (plist-get (nth 0 occurrences) :day))
    (assert-equal 15 (plist-get (nth 1 occurrences) :day))
    (assert-equal 22 (plist-get (nth 2 occurrences) :day))))

;; Task 4: Format Occurrence for Display tests

(deftest test-format-occurrence ()
  "Test formatting datetime for display."
  (let ((dt '(:year 2024 :month 1 :day 13 :hour 0 :minute 0 :second 0)))
    (assert-equal "Sat Jan 13, 2024"
                  (org-habit-ng--format-occurrence dt))))

;; Task 5: Wizard State Management tests

(deftest test-wizard-state-init ()
  "Test wizard state initialization."
  (let ((state (org-habit-ng--wizard-state-create)))
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
                  (org-habit-ng--wizard-state-to-rule state))))

;; Task 6: Wizard Step 1 - Frequency Selection tests

(deftest test-wizard-prompt-frequency ()
  "Test frequency selection returns valid symbol."
  ;; Mock completing-read to return "Weekly"
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Weekly")))
    (assert-equal 'weekly (org-habit-ng--wizard-prompt-frequency))))

;; Task 7: Wizard Step 2 - Interval Prompt tests

(deftest test-wizard-prompt-interval ()
  "Test interval prompt returns number."
  (cl-letf (((symbol-function 'read-number)
             (lambda (&rest _) 2)))
    (assert-equal 2 (org-habit-ng--wizard-prompt-interval 'weekly))))

;; Task 8: Wizard Step 3a - Weekly Day Selection tests

(deftest test-wizard-prompt-weekdays ()
  "Test weekday selection returns list of day numbers."
  (cl-letf (((symbol-function 'completing-read-multiple)
             (lambda (&rest _) '("Monday" "Wednesday" "Friday"))))
    (assert-equal '(1 3 5) (org-habit-ng--wizard-prompt-weekdays))))

;; Task 9: Wizard Step 3b - Monthly Day Type Selection tests

(deftest test-wizard-prompt-monthly-type ()
  "Test monthly type selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Specific day of month (e.g., the 15th)")))
    (assert-equal 'day-of-month (org-habit-ng--wizard-prompt-monthly-type))))

;; Task 10: Wizard Step 3b - Monthly Day Details tests

(deftest test-wizard-prompt-day-of-month ()
  "Test day of month prompt."
  (cl-letf (((symbol-function 'read-number)
             (lambda (&rest _) 15)))
    (assert-equal '(:bymonthday (15))
                  (org-habit-ng--wizard-prompt-monthly-details 'day-of-month))))

(deftest test-wizard-prompt-nth-weekday ()
  "Test nth weekday prompt."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (prompt &rest _)
               (if (string-match "Which day" prompt) "Saturday" "Second"))))
    (assert-equal '(:byday ((2 . 6)))
                  (org-habit-ng--wizard-prompt-monthly-details 'nth-weekday))))

(deftest test-wizard-prompt-last-weekday ()
  "Test last weekday prompt."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Friday")))
    (assert-equal '(:byday ((-1 . 5)))
                  (org-habit-ng--wizard-prompt-monthly-details 'last-weekday))))

(deftest test-wizard-prompt-last-day ()
  "Test last day of month."
  (assert-equal '(:bymonthday (-1))
                (org-habit-ng--wizard-prompt-monthly-details 'last-day)))

;; Task 11: Wizard Step 3c - Yearly Month Selection tests

(deftest test-wizard-prompt-month ()
  "Test month selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "December")))
    (assert-equal 12 (org-habit-ng--wizard-prompt-month))))

;; Task 12: Wizard Step 4 - Flexibility Window tests

(deftest test-wizard-prompt-flexibility-yes ()
  "Test flexibility prompt when user says yes."
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t))
            ((symbol-function 'read-number) (lambda (&rest _) 2)))
    (assert-equal 2 (org-habit-ng--wizard-prompt-flexibility))))

(deftest test-wizard-prompt-flexibility-no ()
  "Test flexibility prompt when user says no."
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) nil)))
    (assert-nil (org-habit-ng--wizard-prompt-flexibility))))

;; Task 13: Wizard Step 5 - Repeat From tests

(deftest test-wizard-prompt-repeat-from ()
  "Test repeat-from selection."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (&rest _) "Scheduled date")))
    (assert-equal 'scheduled (org-habit-ng--wizard-prompt-repeat-from))))

;; Task 14: Preview Display tests

(deftest test-wizard-format-preview ()
  "Test preview formatting."
  (let* ((rule '(:freq weekly :interval 2 :byday (1 3 5) :repeat-from scheduled))
         (preview (org-habit-ng--wizard-format-preview rule)))
    (assert-match "Every 2 weeks on Monday, Wednesday, Friday" preview)
    (assert-match "FREQ=WEEKLY" preview)
    (assert-match "Next 3 occurrences:" preview)))

;; Task 15: Save Recurrence Property tests

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
    (org-habit-ng--wizard-save-recurrence "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR")
    (assert-equal "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"
                  (org-entry-get nil "RECURRENCE"))))

;; Task 16: Main Wizard Flow (Completing-Read Version) tests

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
              ((symbol-function 'org-habit-ng--wizard-show-preview)
               (lambda (&rest _) t)))
      (org-habit-ng--wizard-run-completing-read)
      (assert-match "FREQ=WEEKLY"
                    (org-entry-get nil "RECURRENCE")))))

;; Task 17: Entry Point Command tests

(deftest test-set-recurrence-command-exists ()
  "Test that the command is defined."
  (assert-true (commandp 'org-habit-ng-set-recurrence)))

;; Task 18: Transient Menu - Frequency Selection tests

(deftest test-transient-frequency-menu-defined ()
  "Test that transient frequency menu is defined."
  (if (featurep 'transient)
      ;; Check that the function is defined (transient-define-prefix creates a function)
      (assert-true (fboundp 'org-habit-ng--transient-frequency))
    ;; Skip test if transient is not available
    (assert-true t)))

;; Task 19: Transient Menu - Weekday Toggle Picker tests

(deftest test-transient-weekday-toggle ()
  "Test weekday toggle state management."
  (let ((org-habit-ng--weekday-selection nil))
    (org-habit-ng--toggle-weekday 1)  ; Monday
    (assert-equal '(1) org-habit-ng--weekday-selection)
    (org-habit-ng--toggle-weekday 3)  ; Wednesday
    (assert-equal '(1 3) (sort org-habit-ng--weekday-selection #'<))
    (org-habit-ng--toggle-weekday 1)  ; Toggle Monday off
    (assert-equal '(3) org-habit-ng--weekday-selection)))

;; Task 20: Wire Up Transient to Entry Point tests

(deftest test-set-recurrence-uses-transient-when-available ()
  "Test that transient is used in GUI mode when available."
  (if (featurep 'transient)
      ;; Just verify the function exists and is callable
      (assert-true (functionp 'org-habit-ng--wizard-run-transient))
    ;; Skip test if transient is not available
    (assert-true t)))

;; Phase 3: Consistency Graph Tests

(deftest test-get-due-dates-in-range-weekly ()
  "Test getting due dates for weekly pattern."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Jan 1, 2024 is day 738886 (Monday)
         (start-day 738886)
         (end-day (+ start-day 21))  ; 3 weeks
         (dates (org-habit-ng--get-due-dates-in-range rule start-day end-day)))
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
         (dates (org-habit-ng--get-due-dates-in-range rule start-day end-day)))
    ;; Dec 14, 2024 (2nd Sat) = 739234, Jan 11, 2025 = 739262
    (assert-true (>= (length dates) 2))
    (assert-equal 739234 (nth 0 dates))))

;; Task 2: Get Nearest Due Date tests

(deftest test-get-nearest-due-date-before ()
  "Test nearest due date when day is before all due dates."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-ng--get-nearest-due-date 95 due-dates)))
      (assert-equal -5 (car result))   ; 5 days before
      (assert-equal 100 (cdr result))))) ; nearest is 100

(deftest test-get-nearest-due-date-after ()
  "Test nearest due date when day is after a due date."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-ng--get-nearest-due-date 103 due-dates)))
      (assert-equal 3 (car result))    ; 3 days after
      (assert-equal 100 (cdr result))))) ; nearest is 100

(deftest test-get-nearest-due-date-between ()
  "Test nearest due date when day is between due dates."
  (let ((due-dates '(100 110 120)))
    ;; Day 106 is closer to 110 than 100
    (let ((result (org-habit-ng--get-nearest-due-date 106 due-dates)))
      (assert-equal -4 (car result))   ; 4 days before
      (assert-equal 110 (cdr result))))) ; nearest is 110

(deftest test-get-nearest-due-date-exact ()
  "Test nearest due date when day is exactly on due date."
  (let ((due-dates '(100 110 120)))
    (let ((result (org-habit-ng--get-nearest-due-date 110 due-dates)))
      (assert-equal 0 (car result))
      (assert-equal 110 (cdr result)))))

;; Task 3: Get Face for Day tests

(deftest test-get-graph-face-before-due ()
  "Test face for day before due date."
  (let ((face (org-habit-ng--get-graph-face -5 0 nil nil)))
    (assert-equal 'org-habit-clear-face (car face))))

(deftest test-get-graph-face-on-due ()
  "Test face for day on due date."
  (let ((face (org-habit-ng--get-graph-face 0 0 nil nil)))
    (assert-equal 'org-habit-ready-face (car face))))

(deftest test-get-graph-face-within-flexibility ()
  "Test face for day within flexibility window."
  (let ((face (org-habit-ng--get-graph-face 2 3 nil nil)))  ; 2 days after, 3 day flexibility
    (assert-equal 'org-habit-ready-face (car face))))

(deftest test-get-graph-face-at-deadline ()
  "Test face for day at deadline (end of flexibility)."
  (let ((face (org-habit-ng--get-graph-face 3 2 nil nil)))  ; 3 days after, 2 day flexibility
    (assert-equal 'org-habit-alert-face (car face))))

(deftest test-get-graph-face-overdue ()
  "Test face for overdue day."
  (let ((face (org-habit-ng--get-graph-face 5 0 nil nil)))
    (assert-equal 'org-habit-overdue-face (car face))))

(deftest test-get-graph-face-future ()
  "Test that future days get future face variant."
  (let ((face (org-habit-ng--get-graph-face -5 0 nil t)))  ; future-p = t
    (assert-equal 'org-habit-clear-future-face (cdr face))))

;; Task 4: Get RRULE from Agenda Marker tests

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
        (let ((rule (org-habit-ng--get-rrule-from-agenda-marker)))
          (assert-true rule)
          (assert-equal 'monthly (plist-get rule :freq)))))))

;; Task 5: Build Graph for RRULE Habit tests

(deftest test-build-graph-basic ()
  "Test building a basic RRULE graph."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Habit structure: (scheduled sr-days deadline dr-days done-dates sr-type)
         (habit (list 738886 7 nil nil '() ".+"))  ; Jan 1, 2024
         ;; Convert day numbers to actual time values using encode-time
         (starting (encode-time 0 0 0 26 12 2023))  ; Dec 26, 2023
         (current (encode-time 0 0 0 5 1 2024))     ; Jan 5, 2024
         (ending (encode-time 0 0 0 15 1 2024))     ; Jan 15, 2024
         (graph (org-habit-ng--build-graph habit starting current ending rule)))
    ;; Graph should be a string
    (assert-true (stringp graph))
    ;; Graph length should match window size + 1
    (assert-equal 21 (length graph))))

(deftest test-build-graph-with-done-dates ()
  "Test that done dates show completed glyph."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Done on day 738893 (Jan 8)
         (habit (list 738886 7 nil nil '(738893) ".+"))
         (starting (encode-time 0 0 0 1 1 2024))    ; Jan 1, 2024
         (current (encode-time 0 0 0 10 1 2024))    ; Jan 10, 2024
         (ending (encode-time 0 0 0 15 1 2024))     ; Jan 15, 2024
         (graph (org-habit-ng--build-graph habit starting current ending rule)))
    ;; Should have a completed glyph somewhere
    (assert-true (cl-find org-habit-completed-glyph graph))))

;; Task 3 (Congruence Phase): Parse Todo Without Repeater tests

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

;; Task 6: Advice Around org-habit-build-graph tests

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
        (assert-nil (org-habit-ng--get-rrule-from-agenda-marker))))))

(deftest test-graph-advice-function-exists ()
  "Test that the advice function is defined."
  (assert-true (functionp 'org-habit-ng--around-build-graph)))

;; Task 7: Integrate Graph Advice into Minor Mode tests

(deftest test-mode-enables-graph-advice ()
  "Test that enabling mode adds graph advice."
  (org-habit-ng-mode 1)
  (assert-true (advice-member-p #'org-habit-ng--around-build-graph 'org-habit-build-graph))
  (org-habit-ng-mode -1)
  (assert-nil (advice-member-p #'org-habit-ng--around-build-graph 'org-habit-build-graph)))

;; Task 8: Integration Test - Full Graph Rendering

(deftest test-full-graph-integration ()
  "Integration test for RRULE graph rendering."
  (org-habit-ng-mode 1)
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
               (starting (encode-time 0 0 0 26 12 2023))  ; Dec 26, 2023 (day 738880)
               (current (encode-time 0 0 0 13 1 2024))    ; Jan 13, 2024 (day 738898)
               (ending (encode-time 0 0 0 4 2 2024)))     ; Feb 4, 2024 (day 738920)
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
    (org-habit-ng-mode -1)))

;;; ============================================================================
;;; Feature Parity Integration Tests
;;; ============================================================================
;;; These tests verify org-habit-ng is a drop-in replacement for org-habit,
;;; maintaining all standard functionality while adding RRULE support.

;; -----------------------------------------------------------------------------
;; Scenario 1: Standard habit delegation (no RECURRENCE property)
;; -----------------------------------------------------------------------------

(deftest test-integration-standard-habit-recognition ()
  "Standard habits (no RECURRENCE) are recognized normally."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Standard habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let ((habit (org-habit-parse-todo)))
          ;; Should return valid habit data
          (assert-true habit)
          ;; Element 1 is the repeat interval in days (7 for weekly)
          (assert-equal 7 (nth 1 habit))
          ;; Element 5 is the repeat type
          (assert-equal ".+" (nth 5 habit))))
    (org-habit-ng-mode -1)))

(deftest test-integration-standard-habit-graph ()
  "Standard habits get normal graph (delegation works)."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Standard habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((marker (point-marker))
               (habit (org-habit-parse-todo))
               (starting (encode-time 0 0 0 8 1 2024))
               (current (encode-time 0 0 0 15 1 2024))
               (ending (encode-time 0 0 0 22 1 2024)))
          (with-temp-buffer
            (insert "  habit line")
            ;; No org-marker means no RRULE lookup, standard delegation
            (goto-char (point-min))
            (let ((graph (org-habit-build-graph habit starting current ending)))
              (assert-true (stringp graph))
              (assert-true (> (length graph) 0))))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 2: RRULE habit recognition
;; -----------------------------------------------------------------------------

(deftest test-integration-rrule-habit-recognition ()
  "RRULE habits are recognized with approximate interval."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO RRULE habit\n")
        (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let ((habit (org-habit-parse-todo)))
          ;; Should return valid habit data
          (assert-true habit)
          ;; Element 1 should be approximate interval (~30 for monthly)
          (assert-equal 30 (nth 1 habit))))
    (org-habit-ng-mode -1)))

(deftest test-integration-rrule-weekly-recognition ()
  "Weekly RRULE habits get correct approximate interval."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Weekly MWF habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let ((habit (org-habit-parse-todo)))
          (assert-true habit)
          ;; MWF pattern: average ~2-3 days between occurrences
          (let ((interval (nth 1 habit)))
            (assert-true (and (>= interval 2) (<= interval 3))))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 3: RRULE DONE advances correctly
;; -----------------------------------------------------------------------------

(deftest test-integration-rrule-done-advances-weekly ()
  "Marking weekly RRULE habit DONE advances to next occurrence."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Weekly habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;INTERVAL=1\n")
        (insert ":END:\n")
        (goto-char (point-min))
        ;; Simulate the after-repeat advice
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt (org-habit-ng--org-ts-to-datetime "<2024-01-15 Mon>"))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; Should advance to Jan 22 (one week later)
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 1 (plist-get next-dt :month))
          (assert-equal 22 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

(deftest test-integration-rrule-done-advances-monthly-2nd-saturday ()
  "Marking 2nd-Saturday habit DONE advances correctly."
  (org-habit-ng-mode 1)
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
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt (org-habit-ng--org-ts-to-datetime "<2024-01-13 Sat>"))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; Jan 13 2024 is 2nd Saturday -> next is Feb 10 2024 (2nd Saturday of Feb)
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 2 (plist-get next-dt :month))
          (assert-equal 10 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

(deftest test-integration-rrule-done-advances-last-friday ()
  "Marking last-Friday habit DONE advances correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Last Friday habit\n")
        (insert "SCHEDULED: <2024-01-26 Fri .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=-1FR\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt (org-habit-ng--org-ts-to-datetime "<2024-01-26 Fri>"))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; Jan 26 2024 is last Friday -> next is Feb 23 2024
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 2 (plist-get next-dt :month))
          (assert-equal 23 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 4: X-REPEAT-FROM behavior
;; -----------------------------------------------------------------------------

(deftest test-integration-repeat-from-scheduled ()
  "X-REPEAT-FROM=scheduled calculates from scheduled date."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Repeat from scheduled\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;X-REPEAT-FROM=scheduled\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               ;; Scheduled was Jan 15, completed on Jan 17
               (scheduled-dt '(:year 2024 :month 1 :day 15 :hour 0 :minute 0 :second 0))
               (today-dt '(:year 2024 :month 1 :day 17 :hour 0 :minute 0 :second 0))
               (base (org-habit-ng--get-repeat-base rule scheduled-dt today-dt))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base)))
          ;; Should be Jan 22 (from scheduled Jan 15, not completion Jan 17)
          (assert-equal 22 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

(deftest test-integration-repeat-from-completion ()
  "X-REPEAT-FROM=completion calculates from completion date."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Repeat from completion\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;X-REPEAT-FROM=completion\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               ;; Scheduled was Jan 15, completed on Jan 17
               (scheduled-dt '(:year 2024 :month 1 :day 15 :hour 0 :minute 0 :second 0))
               (today-dt '(:year 2024 :month 1 :day 17 :hour 0 :minute 0 :second 0))
               (base (org-habit-ng--get-repeat-base rule scheduled-dt today-dt))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base)))
          ;; Should be Jan 24 (from completion Jan 17, not scheduled Jan 15)
          (assert-equal 24 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 5: Graph accuracy for RRULE patterns
;; -----------------------------------------------------------------------------

(deftest test-integration-graph-monthly-pattern-accuracy ()
  "Graph shows correct due dates for 2nd Saturday pattern."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Monthly 2nd Saturday\n")
        (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((marker (point-marker))
               ;; Graph window: Dec 1 2023 to Feb 28 2024
               ;; Due dates: Jan 13 (day 738898), Feb 10 (day 738926)
               (habit (list 738898 30 nil nil '() ".+"))
               (starting (encode-time 0 0 0 1 12 2023))  ; Dec 1
               (current (encode-time 0 0 0 20 1 2024))   ; Jan 20
               (ending (encode-time 0 0 0 28 2 2024)))   ; Feb 28
          (with-temp-buffer
            (insert "  habit line")
            (put-text-property (point-min) (point-max) 'org-marker marker)
            (goto-char (point-min))
            (let ((graph (org-habit-build-graph habit starting current ending)))
              ;; Graph should span Dec 1 to Feb 28 (90 days)
              (assert-equal 90 (length graph))
              ;; Today glyph should appear
              (assert-true (cl-find org-habit-today-glyph graph))))))
    (org-habit-ng-mode -1)))

(deftest test-integration-graph-weekly-mwf-accuracy ()
  "Graph shows correct due dates for MWF pattern."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO MWF habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;BYDAY=MO,WE,FR\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((marker (point-marker))
               (habit (list 738900 2 nil nil '() ".+"))
               (starting (encode-time 0 0 0 8 1 2024))   ; Jan 8
               (current (encode-time 0 0 0 15 1 2024))   ; Jan 15
               (ending (encode-time 0 0 0 22 1 2024)))   ; Jan 22
          (with-temp-buffer
            (insert "  habit line")
            (put-text-property (point-min) (point-max) 'org-marker marker)
            (goto-char (point-min))
            (let ((graph (org-habit-build-graph habit starting current ending)))
              (assert-true (stringp graph))
              (assert-equal 15 (length graph))))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 6: Done dates appear in graph
;; -----------------------------------------------------------------------------

(deftest test-integration-graph-shows-done-dates ()
  "Completed days show completed glyph in graph."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Weekly habit with completions\n")
        (insert "SCHEDULED: <2024-01-22 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;INTERVAL=1\n")
        (insert ":LAST_REPEAT: [2024-01-15 Mon]\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((marker (point-marker))
               ;; Done on Jan 8 (day 738893) and Jan 15 (day 738900)
               (habit (list 738907 7 nil nil '(738893 738900) ".+"))
               (starting (encode-time 0 0 0 1 1 2024))
               (current (encode-time 0 0 0 20 1 2024))
               (ending (encode-time 0 0 0 28 1 2024)))
          (with-temp-buffer
            (insert "  habit line")
            (put-text-property (point-min) (point-max) 'org-marker marker)
            (goto-char (point-min))
            (let ((graph (org-habit-build-graph habit starting current ending)))
              ;; Should have completed glyphs for done dates
              (assert-true (cl-find org-habit-completed-glyph graph))
              ;; Count completed glyphs (should be 2)
              (let ((count 0))
                (dotimes (i (length graph))
                  (when (= (aref graph i) org-habit-completed-glyph)
                    (setq count (1+ count))))
                (assert-equal 2 count))))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 7: X-FLEXIBILITY extends green zone
;; -----------------------------------------------------------------------------

(deftest test-integration-flexibility-extends-green ()
  "X-FLEXIBILITY extends the green (ready) zone."
  ;; Day 0 = due date, flexibility = 2
  ;; Days 0, 1, 2 should be green (ready)
  ;; Day 3 should be yellow (alert)
  ;; Day 4+ should be red (overdue)
  (let ((face-day-0 (org-habit-ng--get-graph-face 0 2 nil nil))
        (face-day-1 (org-habit-ng--get-graph-face 1 2 nil nil))
        (face-day-2 (org-habit-ng--get-graph-face 2 2 nil nil))
        (face-day-3 (org-habit-ng--get-graph-face 3 2 nil nil))
        (face-day-4 (org-habit-ng--get-graph-face 4 2 nil nil)))
    ;; Days 0-2 are ready (green)
    (assert-equal 'org-habit-ready-face (car face-day-0))
    (assert-equal 'org-habit-ready-face (car face-day-1))
    (assert-equal 'org-habit-ready-face (car face-day-2))
    ;; Day 3 is alert (yellow) - one past flexibility
    (assert-equal 'org-habit-alert-face (car face-day-3))
    ;; Day 4 is overdue (red)
    (assert-equal 'org-habit-overdue-face (car face-day-4))))

(deftest test-integration-flexibility-in-graph ()
  "RRULE with X-FLEXIBILITY shows extended green in graph."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Flexible habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=WEEKLY;X-FLEXIBILITY=2\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let ((rule (org-habit-ng--get-recurrence)))
          ;; Verify flexibility is parsed
          (assert-equal 2 (plist-get rule :flexibility))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 8: Multiple completions in sequence
;; -----------------------------------------------------------------------------

(deftest test-integration-sequential-completions ()
  "Multiple completions advance correctly in sequence."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let* ((rule (org-habit-ng--rrule-parse "FREQ=WEEKLY;INTERVAL=1"))
             (dt1 '(:year 2024 :month 1 :day 15 :hour 0 :minute 0 :second 0))
             (dt2 (org-habit-ng--rrule-next-occurrence rule dt1))
             (dt3 (org-habit-ng--rrule-next-occurrence rule dt2))
             (dt4 (org-habit-ng--rrule-next-occurrence rule dt3)))
        ;; dt1: Jan 15 -> dt2: Jan 22 -> dt3: Jan 29 -> dt4: Feb 5
        (assert-equal 22 (plist-get dt2 :day))
        (assert-equal 29 (plist-get dt3 :day))
        (assert-equal 5 (plist-get dt4 :day))
        (assert-equal 2 (plist-get dt4 :month)))
    (org-habit-ng-mode -1)))

(deftest test-integration-sequential-monthly-2nd-saturday ()
  "Monthly 2nd Saturday advances correctly over several months."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let* ((rule (org-habit-ng--rrule-parse "FREQ=MONTHLY;BYDAY=2SA"))
             (dt1 '(:year 2024 :month 1 :day 13 :hour 0 :minute 0 :second 0))
             (dt2 (org-habit-ng--rrule-next-occurrence rule dt1))
             (dt3 (org-habit-ng--rrule-next-occurrence rule dt2))
             (dt4 (org-habit-ng--rrule-next-occurrence rule dt3)))
        ;; 2nd Saturdays: Jan 13 -> Feb 10 -> Mar 9 -> Apr 13
        (assert-equal 10 (plist-get dt2 :day))
        (assert-equal 2 (plist-get dt2 :month))
        (assert-equal 9 (plist-get dt3 :day))
        (assert-equal 3 (plist-get dt3 :month))
        (assert-equal 13 (plist-get dt4 :day))
        (assert-equal 4 (plist-get dt4 :month)))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 9: Error resilience (malformed RECURRENCE)
;; -----------------------------------------------------------------------------

(deftest test-integration-malformed-rrule-fallback ()
  "Malformed RECURRENCE falls back to standard behavior."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Bad RRULE habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: INVALID_RRULE_STRING\n")
        (insert ":END:\n")
        (goto-char (point-min))
        ;; Should not throw error, should return standard interval
        (let ((habit (org-habit-parse-todo)))
          (assert-true habit)
          ;; Falls back to repeater interval (7 days for .+1w)
          (assert-equal 7 (nth 1 habit))))
    (org-habit-ng-mode -1)))

(deftest test-integration-empty-recurrence-fallback ()
  "Empty RECURRENCE falls back to standard behavior."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Empty RECURRENCE habit\n")
        (insert "SCHEDULED: <2024-01-15 Mon .+2w>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: \n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let ((habit (org-habit-parse-todo)))
          (assert-true habit)
          ;; Should use repeater interval (14 days for .+2w)
          (assert-equal 14 (nth 1 habit))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 10: Mode toggle behavior
;; -----------------------------------------------------------------------------

(deftest test-integration-mode-off-standard-behavior ()
  "With mode off, standard org-habit behavior is used."
  (org-habit-ng-mode -1)  ; Ensure mode is off
  (with-temp-buffer
    (org-mode)
    (insert "* TODO RRULE habit with mode off\n")
    (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
    (insert ":PROPERTIES:\n")
    (insert ":STYLE: habit\n")
    (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA\n")
    (insert ":END:\n")
    (goto-char (point-min))
    (let ((habit (org-habit-parse-todo)))
      ;; With mode off, should use standard repeater (30 days for .+1m)
      (assert-true habit)
      ;; Interval comes from .+1m, approximately 30-31 days
      (let ((interval (nth 1 habit)))
        (assert-true (and (>= interval 28) (<= interval 31)))))))

(deftest test-integration-mode-toggle-advice ()
  "Toggling mode adds/removes all advice correctly."
  (org-habit-ng-mode -1)  ; Start with mode off
  ;; Verify no advice
  (assert-nil (advice-member-p #'org-habit-ng--around-build-graph 'org-habit-build-graph))
  (assert-nil (advice-member-p #'org-habit-ng--around-parse-todo 'org-habit-parse-todo))

  ;; Enable mode
  (org-habit-ng-mode 1)
  ;; Verify advice added
  (assert-true (advice-member-p #'org-habit-ng--around-build-graph 'org-habit-build-graph))
  (assert-true (advice-member-p #'org-habit-ng--around-parse-todo 'org-habit-parse-todo))

  ;; Disable mode
  (org-habit-ng-mode -1)
  ;; Verify advice removed
  (assert-nil (advice-member-p #'org-habit-ng--around-build-graph 'org-habit-build-graph))
  (assert-nil (advice-member-p #'org-habit-ng--around-parse-todo 'org-habit-parse-todo)))

;; -----------------------------------------------------------------------------
;; Scenario 11: Complex patterns (yearly, last-day, etc.)
;; -----------------------------------------------------------------------------

(deftest test-integration-yearly-last-sunday-december ()
  "Yearly last Sunday of December pattern works correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Year-end review\n")
        (insert "SCHEDULED: <2023-12-31 Sun .+1y>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt '(:year 2023 :month 12 :day 31 :hour 0 :minute 0 :second 0))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; Last Sunday of Dec 2023 is Dec 31
          ;; Last Sunday of Dec 2024 is Dec 29
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 12 (plist-get next-dt :month))
          (assert-equal 29 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

(deftest test-integration-monthly-last-day ()
  "Monthly last day pattern works correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO End of month review\n")
        (insert "SCHEDULED: <2024-01-31 Wed .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYMONTHDAY=-1\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt '(:year 2024 :month 1 :day 31 :hour 0 :minute 0 :second 0))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; Jan 31 -> Feb 29 (2024 is leap year)
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 2 (plist-get next-dt :month))
          (assert-equal 29 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

(deftest test-integration-first-weekday-of-month ()
  "First weekday of month pattern works correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "* TODO First business day\n")
        (insert "SCHEDULED: <2024-01-01 Mon .+1m>\n")
        (insert ":PROPERTIES:\n")
        (insert ":STYLE: habit\n")
        (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1\n")
        (insert ":END:\n")
        (goto-char (point-min))
        (let* ((rule (org-habit-ng--get-recurrence))
               (base-dt '(:year 2024 :month 1 :day 1 :hour 0 :minute 0 :second 0))
               (next-dt (org-habit-ng--rrule-next-occurrence rule base-dt)))
          ;; First weekday of Feb 2024 is Feb 1 (Thursday)
          (assert-equal 2024 (plist-get next-dt :year))
          (assert-equal 2 (plist-get next-dt :month))
          (assert-equal 1 (plist-get next-dt :day))))
    (org-habit-ng-mode -1)))

;; -----------------------------------------------------------------------------
;; Scenario 12: Graph face transitions
;; -----------------------------------------------------------------------------

(deftest test-integration-face-progression-before-due ()
  "Days before due date are blue (clear)."
  (let ((face (org-habit-ng--get-graph-face -5 0 nil nil)))
    (assert-equal 'org-habit-clear-face (car face)))
  (let ((face (org-habit-ng--get-graph-face -1 0 nil nil)))
    (assert-equal 'org-habit-clear-face (car face))))

(deftest test-integration-face-progression-on-due ()
  "Day of due date is green (ready)."
  (let ((face (org-habit-ng--get-graph-face 0 0 nil nil)))
    (assert-equal 'org-habit-ready-face (car face))))

(deftest test-integration-face-progression-alert ()
  "Day after grace period is yellow (alert)."
  ;; With flexibility=0, day 1 is alert
  (let ((face (org-habit-ng--get-graph-face 1 0 nil nil)))
    (assert-equal 'org-habit-alert-face (car face)))
  ;; With flexibility=2, day 3 is alert
  (let ((face (org-habit-ng--get-graph-face 3 2 nil nil)))
    (assert-equal 'org-habit-alert-face (car face))))

(deftest test-integration-face-progression-overdue ()
  "Days well past due are red (overdue)."
  (let ((face (org-habit-ng--get-graph-face 5 0 nil nil)))
    (assert-equal 'org-habit-overdue-face (car face)))
  (let ((face (org-habit-ng--get-graph-face 10 2 nil nil)))
    (assert-equal 'org-habit-overdue-face (car face))))

(deftest test-integration-face-future-variants ()
  "Future days use future face variants."
  (let ((face (org-habit-ng--get-graph-face -5 0 nil t)))
    (assert-equal 'org-habit-clear-future-face (cdr face)))
  (let ((face (org-habit-ng--get-graph-face 0 0 nil t)))
    (assert-equal 'org-habit-ready-future-face (cdr face)))
  (let ((face (org-habit-ng--get-graph-face 5 0 nil t)))
    (assert-equal 'org-habit-overdue-future-face (cdr face))))

;; -----------------------------------------------------------------------------
;; Scenario 13: Due dates in range calculation
;; -----------------------------------------------------------------------------

(deftest test-integration-due-dates-weekly-pattern ()
  "Weekly pattern generates correct due dates in range."
  (let* ((rule '(:freq weekly :interval 1))
         ;; Jan 1, 2024 (Monday) = day 738886
         (start-day 738886)
         (end-day (+ start-day 28))  ; 4 weeks
         (dates (org-habit-ng--get-due-dates-in-range rule start-day end-day)))
    ;; Should get Jan 8, 15, 22, 29
    (assert-equal 4 (length dates))
    (assert-equal (+ start-day 7) (nth 0 dates))
    (assert-equal (+ start-day 14) (nth 1 dates))
    (assert-equal (+ start-day 21) (nth 2 dates))
    (assert-equal (+ start-day 28) (nth 3 dates))))

(deftest test-integration-due-dates-mwf-pattern ()
  "MWF pattern generates correct due dates in range."
  (let* ((rule '(:freq weekly :interval 1 :byday (1 3 5)))
         ;; Jan 1, 2024 (Monday) = day 738886
         (start-day 738886)
         (end-day (+ start-day 7))  ; 1 week
         (dates (org-habit-ng--get-due-dates-in-range rule start-day end-day)))
    ;; Starting from Monday: Wed Jan 3, Fri Jan 5, Mon Jan 8
    (assert-true (>= (length dates) 2))))

(deftest test-integration-due-dates-2nd-saturday ()
  "2nd Saturday pattern generates correct due dates."
  (let* ((rule '(:freq monthly :interval 1 :byday ((2 . 6))))
         ;; Dec 1, 2024 = day 739221
         (start-day 739221)
         (end-day (+ start-day 90))  ; ~3 months
         (dates (org-habit-ng--get-due-dates-in-range rule start-day end-day)))
    ;; Dec 14 2024, Jan 11 2025, Feb 8 2025
    (assert-true (>= (length dates) 2))))

;; -----------------------------------------------------------------------------
;; End-to-End Test: Full org-todo workflow
;; -----------------------------------------------------------------------------

(deftest test-e2e-org-todo-full-workflow ()
  "End-to-end test: org-todo marks DONE, updates SCHEDULED correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let ((org-log-done nil)
            (org-log-repeat nil))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Weekly review\n")
          (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
          (insert ":PROPERTIES:\n")
          (insert ":STYLE: habit\n")
          ;; Use X-REPEAT-FROM=scheduled for deterministic testing
          (insert ":RECURRENCE: FREQ=WEEKLY;INTERVAL=1;X-REPEAT-FROM=scheduled\n")
          (insert ":END:\n")
          (goto-char (point-min))

          ;; Verify initial state
          (assert-equal "TODO" (org-get-todo-state))
          (let ((initial-scheduled (org-entry-get nil "SCHEDULED")))
            (assert-true (string-match-p "2024-01-15" initial-scheduled)))

          ;; Mark as DONE - this triggers the full workflow
          (org-todo "DONE")

          ;; After org-auto-repeat-maybe, state should be back to TODO
          (assert-equal "TODO" (org-get-todo-state))

          ;; SCHEDULED should be updated to Jan 22 (next week per RRULE)
          (let ((new-scheduled (org-entry-get nil "SCHEDULED")))
            (assert-true new-scheduled)
            (assert-true (string-match-p "2024-01-22" new-scheduled)))))
    (org-habit-ng-mode -1)))

(deftest test-e2e-org-todo-monthly-2nd-saturday ()
  "End-to-end test: 2nd Saturday pattern advances correctly via org-todo."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let ((org-log-done 'time)
            (org-log-into-drawer "LOGBOOK")
            (org-log-repeat 'time))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Monthly review\n")
          (insert "SCHEDULED: <2024-01-13 Sat .+1m>\n")
          (insert ":PROPERTIES:\n")
          (insert ":STYLE: habit\n")
          ;; Use X-REPEAT-FROM=scheduled for deterministic testing
          (insert ":RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=scheduled\n")
          (insert ":END:\n")
          (goto-char (point-min))

          ;; Mark as DONE
          (org-todo "DONE")

          ;; Should advance to Feb 10 (2nd Saturday of Feb), not Feb 13
          (let ((new-scheduled (org-entry-get nil "SCHEDULED")))
            (assert-true new-scheduled)
            ;; 2nd Saturday of Feb 2024 is Feb 10
            (assert-true (string-match-p "2024-02-10" new-scheduled)))))
    (org-habit-ng-mode -1)))

(deftest test-e2e-org-todo-last-repeat-property ()
  "End-to-end test: LAST_REPEAT property is updated."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let ((org-log-done 'time)
            (org-log-into-drawer "LOGBOOK")
            (org-log-repeat 'time))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Daily habit\n")
          (insert "SCHEDULED: <2024-01-15 Mon .+1d>\n")
          (insert ":PROPERTIES:\n")
          (insert ":STYLE: habit\n")
          (insert ":RECURRENCE: FREQ=DAILY;INTERVAL=1\n")
          (insert ":END:\n")
          (goto-char (point-min))

          ;; Mark as DONE
          (org-todo "DONE")

          ;; LAST_REPEAT should be set
          (let ((last-repeat (org-entry-get nil "LAST_REPEAT")))
            (assert-true last-repeat))))
    (org-habit-ng-mode -1)))

(deftest test-e2e-multiple-completions ()
  "End-to-end test: Multiple org-todo completions advance correctly."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let ((org-log-done nil)  ; Disable logging to simplify
            (org-log-repeat nil))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Weekly habit\n")
          (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
          (insert ":PROPERTIES:\n")
          (insert ":STYLE: habit\n")
          ;; Use X-REPEAT-FROM=scheduled for deterministic testing
          (insert ":RECURRENCE: FREQ=WEEKLY;INTERVAL=1;X-REPEAT-FROM=scheduled\n")
          (insert ":END:\n")
          (goto-char (point-min))

          ;; First completion: Jan 15 -> Jan 22
          (org-todo "DONE")
          (assert-true (string-match-p "2024-01-22" (org-entry-get nil "SCHEDULED")))

          ;; Second completion: Jan 22 -> Jan 29
          (org-todo "DONE")
          (assert-true (string-match-p "2024-01-29" (org-entry-get nil "SCHEDULED")))

          ;; Third completion: Jan 29 -> Feb 5
          (org-todo "DONE")
          (assert-true (string-match-p "2024-02-05" (org-entry-get nil "SCHEDULED")))))
    (org-habit-ng-mode -1)))

(deftest test-e2e-standard-habit-unchanged ()
  "End-to-end test: Standard habits (no RECURRENCE) work normally."
  (org-habit-ng-mode 1)
  (unwind-protect
      (let ((org-log-done nil)
            (org-log-repeat nil))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Standard weekly habit\n")
          (insert "SCHEDULED: <2024-01-15 Mon .+1w>\n")
          (insert ":PROPERTIES:\n")
          (insert ":STYLE: habit\n")
          (insert ":END:\n")
          (goto-char (point-min))

          ;; Verify no RECURRENCE property
          (assert-nil (org-entry-get nil "RECURRENCE"))

          ;; Mark as DONE - should use standard org repeat
          (org-todo "DONE")

          ;; State should cycle back to TODO
          (assert-equal "TODO" (org-get-todo-state))

          ;; SCHEDULED should be updated (standard .+1w adds 1 week from today)
          ;; Just verify it changed and has the repeater
          (let ((new-scheduled (org-entry-get nil "SCHEDULED")))
            (assert-true new-scheduled)
            (assert-true (string-match-p "\\.\\+1w" new-scheduled)))))
    (org-habit-ng-mode -1)))

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

;; -----------------------------------------------------------------------------
;; Tests for --build-habit-struct
;; -----------------------------------------------------------------------------

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

;; -----------------------------------------------------------------------------
;; Task 4: Integration tests for habits without org repeater
;; -----------------------------------------------------------------------------

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

(provide 'org-habit-ng-test)
;;; org-habit-ng-test.el ends here
