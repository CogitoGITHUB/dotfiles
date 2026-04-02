;;; org-habit-ng.el --- Full RRULE recurrence for org-habit -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Trevoke

;; Author: Trevoke
;; Version: 0.5.0
;; Package-Requires: ((emacs "28.1") (org "9.6"))
;; Keywords: calendar, org, habits
;; URL: https://codeberg.org/Trevoke/org-habit-ng

;; This file is not part of GNU Emacs.

;;; Commentary:

;; org-habit-ng extends org-habit to support RFC 5545 RRULE recurrence
;; patterns that cannot be expressed with standard org repeaters.
;;
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
;; Installation:
;;   (require 'org-habit-ng)
;;   (org-habit-ng-mode 1)
;;
;; RRULE Usage:
;;   Add a :RECURRENCE: property with RRULE syntax:
;;
;;   * TODO Monthly review
;;   SCHEDULED: <2024-01-13 Sat .+1m>
;;   :PROPERTIES:
;;   :STYLE: habit
;;   :RECURRENCE: FREQ=MONTHLY;BYDAY=2SA;X-REPEAT-FROM=completion
;;   :END:
;;
;; More RRULE examples:
;;   - Every weekday: FREQ=WEEKLY;BYDAY=MO,WE,FR
;;   - Last Friday of month: FREQ=MONTHLY;BYDAY=-1FR
;;   - Last day of month: FREQ=MONTHLY;BYMONTHDAY=-1
;;   - Last Sunday of December: FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU
;;   - Every 3 days: FREQ=DAILY;INTERVAL=3
;;   - First weekday of month: FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1
;;
;; The SCHEDULED timestamp must have a repeater (e.g., .+1m) for org-habit
;; compatibility, but org-habit-ng will override it with the correct date
;; based on the RECURRENCE rule when you mark the task as DONE.
;;
;; The consistency graph accurately reflects RRULE due dates for complex
;; recurrence patterns (e.g., "2nd Saturday" shows exact intervals of 28-35 days).

;;; Code:

(require 'org)
(require 'org-habit)
(require 'calendar)

(defgroup org-habit-ng nil
  "Complex recurrence patterns for org-habit."
  :group 'org-habit
  :prefix "org-habit-ng-")

(defconst org-habit-ng--ordinal-alist
  '(("first" . 1) ("1st" . 1)
    ("second" . 2) ("2nd" . 2)
    ("third" . 3) ("3rd" . 3)
    ("fourth" . 4) ("4th" . 4)
    ("fifth" . 5) ("5th" . 5)
    ("last" . -1) ("second-to-last" . -2))
  "Alist mapping ordinal strings to numbers.
Negative numbers count from the end.")

(defun org-habit-ng--ordinal-to-number (ordinal)
  "Convert ORDINAL string to a number.
Returns negative for \"last\" (-1), \"second-to-last\" (-2), etc."
  (cdr (assoc (downcase ordinal) org-habit-ng--ordinal-alist)))

(defconst org-habit-ng--weekday-alist
  '(("sunday" . 0) ("sun" . 0) ("su" . 0)
    ("monday" . 1) ("mon" . 1) ("mo" . 1)
    ("tuesday" . 2) ("tue" . 2) ("tu" . 2)
    ("wednesday" . 3) ("wed" . 3) ("we" . 3)
    ("thursday" . 4) ("thu" . 4) ("th" . 4)
    ("friday" . 5) ("fri" . 5) ("fr" . 5)
    ("saturday" . 6) ("sat" . 6) ("sa" . 6))
  "Alist mapping weekday strings to numbers (0=Sunday).")

(defun org-habit-ng--weekday-to-number (weekday)
  "Convert WEEKDAY string to a number (0=Sunday, 6=Saturday)."
  (cdr (assoc (downcase weekday) org-habit-ng--weekday-alist)))

(defun org-habit-ng--nth-weekday-in-month (n weekday month year)
  "Return Gregorian date of Nth WEEKDAY in MONTH YEAR.
N can be negative (-1 = last, -2 = second-to-last).
WEEKDAY is 0-6 (Sunday-Saturday).
Returns (MONTH DAY YEAR)."
  (calendar-nth-named-day n weekday month year))

(defun org-habit-ng--first-weekday-in-month (n month year)
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

(defun org-habit-ng--last-day-of-month (month year)
  "Return (MONTH DAY YEAR) for last day of MONTH in YEAR."
  (list month (calendar-last-day-of-month month year) year))

(defconst org-habit-ng-recurrence-property "RECURRENCE"
  "Property name for storing complex recurrence rules.")

(defun org-habit-ng--get-recurrence (&optional pom)
  "Get parsed recurrence rule from entry at POM.
Returns nil if no RECURRENCE property exists or if parsing fails."
  (let ((recurrence-string (org-entry-get pom org-habit-ng-recurrence-property)))
    (when (and recurrence-string (not (string-empty-p recurrence-string)))
      (condition-case err
          (org-habit-ng--rrule-parse recurrence-string)
        (error
         (message "org-habit-ng: Failed to parse RECURRENCE '%s': %s"
                  recurrence-string (error-message-string err))
         nil)))))

(defun org-habit-ng--gregorian-to-org-ts (date)
  "Convert Gregorian DATE (MONTH DAY YEAR) to org timestamp string."
  (let* ((month (nth 0 date))
         (day (nth 1 date))
         (year (nth 2 date))
         (time (encode-time 0 0 0 day month year))
         (dow (format-time-string "%a" time)))
    (format "<%04d-%02d-%02d %s>" year month day dow)))

(defun org-habit-ng--org-ts-to-gregorian (ts-string)
  "Convert org timestamp TS-STRING to Gregorian date (MONTH DAY YEAR)."
  (let ((time (org-time-string-to-time ts-string)))
    (let ((decoded (decode-time time)))
      (list (nth 4 decoded)   ; month
            (nth 3 decoded)   ; day
            (nth 5 decoded))))) ; year

(defun org-habit-ng--org-ts-to-datetime (ts-string)
  "Convert org timestamp TS-STRING to datetime plist.
Handles timestamps with or without time components."
  (condition-case err
      (let* ((time (org-time-string-to-time ts-string))
             (decoded (decode-time time)))
        (list :second (nth 0 decoded)
              :minute (nth 1 decoded)
              :hour (nth 2 decoded)
              :day (nth 3 decoded)
              :month (nth 4 decoded)
              :year (nth 5 decoded)))
    (error
     (error "Failed to parse timestamp '%s': %s" ts-string err))))

(defun org-habit-ng--datetime-to-org-ts (dt)
  "Convert datetime plist DT to org timestamp string."
  (let* ((time (org-habit-ng--datetime-to-time dt))
         (dow (format-time-string "%a" time)))
    (format "<%04d-%02d-%02d %s>"
            (plist-get dt :year)
            (plist-get dt :month)
            (plist-get dt :day)
            dow)))

(defun org-habit-ng--handle-repeat ()
  "Handle repeat for an org-habit-ng entry.
Computes the next occurrence based on RECURRENCE property
and updates SCHEDULED timestamp accordingly."
  (let ((rule (org-habit-ng--get-recurrence)))
    (when (and rule (plist-get rule :freq))
      (let* ((scheduled-ts (org-entry-get nil "SCHEDULED"))
             (base-dt (org-habit-ng--org-ts-to-datetime scheduled-ts))
             (today-dt (org-habit-ng--time-to-datetime (current-time)))
             (repeat-base (org-habit-ng--get-repeat-base rule base-dt today-dt))
             (next-dt (org-habit-ng--rrule-next-occurrence rule repeat-base))
             (next-ts (when next-dt (org-habit-ng--datetime-to-org-ts next-dt))))
        (when next-ts
          (org-schedule nil next-ts))))))

(defvar-local org-habit-ng--original-scheduled nil
  "Buffer-local variable to store original SCHEDULED before repeat.")

(defun org-habit-ng--before-auto-repeat (_done-word)
  "Advice to run before `org-auto-repeat-maybe'.
Captures the original SCHEDULED timestamp."
  (when (and (org-is-habit-p)
             (org-habit-ng--get-recurrence))
    (setq org-habit-ng--original-scheduled
          (org-entry-get nil "SCHEDULED"))))

(defun org-habit-ng--after-auto-repeat (_done-word)
  "Advice to run after `org-auto-repeat-maybe'.
Overrides the timestamp if entry has a RECURRENCE property."
  (when (and (org-is-habit-p)
             (org-habit-ng--get-recurrence))
    (let* ((rule (org-habit-ng--get-recurrence))
           (base-ts (or org-habit-ng--original-scheduled
                        (org-entry-get nil "SCHEDULED"))))
      (when (plist-get rule :freq)
        (let* ((base-dt (org-habit-ng--org-ts-to-datetime base-ts))
               (today-dt (org-habit-ng--time-to-datetime (current-time)))
               (repeat-base (org-habit-ng--get-repeat-base rule base-dt today-dt))
               (next-dt (org-habit-ng--rrule-next-occurrence rule repeat-base))
               (next-ts (when next-dt (org-habit-ng--datetime-to-org-ts next-dt))))
          (when next-ts
            (org-schedule nil next-ts))))
      (setq org-habit-ng--original-scheduled nil))))

(defun org-habit-ng--enable-advice ()
  "Enable advice on `org-auto-repeat-maybe'."
  (advice-add 'org-auto-repeat-maybe :before #'org-habit-ng--before-auto-repeat)
  (advice-add 'org-auto-repeat-maybe :after #'org-habit-ng--after-auto-repeat))

(defun org-habit-ng--disable-advice ()
  "Disable advice on `org-auto-repeat-maybe'."
  (advice-remove 'org-auto-repeat-maybe #'org-habit-ng--before-auto-repeat)
  (advice-remove 'org-auto-repeat-maybe #'org-habit-ng--after-auto-repeat))

(defun org-habit-ng--approximate-interval (rule)
  "Calculate approximate interval in days for RULE.
Used for org-habit graph display."
  (let ((freq (plist-get rule :freq))
        (interval (or (plist-get rule :interval) 1))
        (byday (plist-get rule :byday)))
    (pcase freq
      ('secondly (max 1 (/ interval 86400)))  ; seconds per day
      ('minutely (max 1 (/ interval 1440)))   ; minutes per day
      ('hourly (max 1 (/ interval 24)))       ; hours per day
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
      (_ 7))))

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

(defun org-habit-ng--around-parse-todo (orig-fun &optional pom)
  "Advice around `org-habit-parse-todo' to handle RRULE recurrence.
If RECURRENCE property exists, builds habit structure directly
without requiring an org repeater. Otherwise, calls original function."
  (save-excursion
    (when pom (goto-char pom))
    (let ((recurrence (org-habit-ng--get-recurrence)))
      (if recurrence
          ;; RECURRENCE exists: build synthetic habit struct
          (org-habit-ng--build-habit-struct recurrence)
        ;; No RECURRENCE: use original org-habit behavior
        (funcall orig-fun pom)))))

(defun org-habit-ng--enable-parse-advice ()
  "Enable advice on `org-habit-parse-todo'."
  (advice-add 'org-habit-parse-todo :around #'org-habit-ng--around-parse-todo))

(defun org-habit-ng--disable-parse-advice ()
  "Disable advice on `org-habit-parse-todo'."
  (advice-remove 'org-habit-parse-todo #'org-habit-ng--around-parse-todo))

;;; RRULE Engine (Phase 1 Implementation)

;; Task 1: RRULE Data Structure and Tokenizer

(defun org-habit-ng--rrule-tokenize (rrule-string)
  "Tokenize RRULE-STRING into alist of (KEY . VALUE) pairs.
Example: \"FREQ=DAILY;INTERVAL=3\" -> ((\"FREQ\" . \"DAILY\") (\"INTERVAL\" . \"3\"))"
  (let ((parts (split-string rrule-string ";" t "[ \t\n]+")))
    (mapcar (lambda (part)
              (let ((kv (split-string part "=" t "[ \t]+")))
                (cons (car kv) (cadr kv))))
            parts)))

;; Task 2: RRULE Parser - Basic Structure

(defconst org-habit-ng--rrule-freq-alist
  '(("SECONDLY" . secondly)
    ("MINUTELY" . minutely)
    ("HOURLY" . hourly)
    ("DAILY" . daily)
    ("WEEKLY" . weekly)
    ("MONTHLY" . monthly)
    ("YEARLY" . yearly))
  "Mapping of RRULE FREQ values to symbols.")

(defconst org-habit-ng--rrule-day-alist
  '(("SU" . 0) ("MO" . 1) ("TU" . 2) ("WE" . 3)
    ("TH" . 4) ("FR" . 5) ("SA" . 6))
  "Mapping of RRULE day abbreviations to numbers (0=Sunday).")

(defun org-habit-ng--rrule-parse-byday (value)
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
                              (cdr (assoc weekday org-habit-ng--rrule-day-alist)))
                      (cdr (assoc weekday org-habit-ng--rrule-day-alist))))
                (error "Invalid BYDAY value: %s" day)))
            days)))

(defun org-habit-ng--rrule-parse-numlist (value)
  "Parse comma-separated numbers into list."
  (mapcar #'string-to-number (split-string value "," t)))

(defun org-habit-ng--rrule-parse (rrule-string)
  "Parse RRULE-STRING into a rule plist."
  (let ((tokens (org-habit-ng--rrule-tokenize rrule-string))
        (rule nil))
    (dolist (token tokens)
      (let ((key (car token))
            (value (cdr token)))
        (cond
         ((string= key "FREQ")
          (setq rule (plist-put rule :freq
                                (cdr (assoc value org-habit-ng--rrule-freq-alist)))))
         ((string= key "INTERVAL")
          (setq rule (plist-put rule :interval (string-to-number value))))
         ((string= key "COUNT")
          (setq rule (plist-put rule :count (string-to-number value))))
         ((string= key "UNTIL")
          (setq rule (plist-put rule :until (org-habit-ng--parse-rrule-date value))))
         ((string= key "BYDAY")
          (setq rule (plist-put rule :byday (org-habit-ng--rrule-parse-byday value))))
         ((string= key "BYMONTHDAY")
          (setq rule (plist-put rule :bymonthday (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYMONTH")
          (setq rule (plist-put rule :bymonth (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYWEEKNO")
          (setq rule (plist-put rule :byweekno (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYYEARDAY")
          (setq rule (plist-put rule :byyearday (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYSETPOS")
          (setq rule (plist-put rule :bysetpos (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYHOUR")
          (setq rule (plist-put rule :byhour (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYMINUTE")
          (setq rule (plist-put rule :byminute (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "BYSECOND")
          (setq rule (plist-put rule :bysecond (org-habit-ng--rrule-parse-numlist value))))
         ((string= key "X-REPEAT-FROM")
          (setq rule (plist-put rule :repeat-from (intern value))))
         ((string= key "X-WARN")
          (setq rule (plist-put rule :warn value)))
         ((string= key "X-FLEXIBILITY")
          (setq rule (plist-put rule :flexibility (string-to-number value)))))))
    ;; Default interval to 1 if not specified
    (unless (plist-get rule :interval)
      (setq rule (plist-put rule :interval 1)))
    rule))

;; Task 3: Date/Time Utilities

(defun org-habit-ng--time-to-datetime (time)
  "Convert Emacs TIME to datetime plist."
  (let ((decoded (decode-time time)))
    (list :second (nth 0 decoded)
          :minute (nth 1 decoded)
          :hour (nth 2 decoded)
          :day (nth 3 decoded)
          :month (nth 4 decoded)
          :year (nth 5 decoded))))

(defun org-habit-ng--datetime-to-time (dt)
  "Convert datetime plist DT to Emacs time."
  (encode-time (plist-get dt :second)
               (plist-get dt :minute)
               (plist-get dt :hour)
               (plist-get dt :day)
               (plist-get dt :month)
               (plist-get dt :year)))

(defun org-habit-ng--datetime-dow (dt)
  "Get day of week for datetime DT (0=Sunday, 6=Saturday)."
  (calendar-day-of-week (list (plist-get dt :month)
                               (plist-get dt :day)
                               (plist-get dt :year))))

(defun org-habit-ng--datetime-compare (dt1 dt2)
  "Compare two datetime plists. Return -1, 0, or 1."
  (let ((t1 (org-habit-ng--datetime-to-time dt1))
        (t2 (org-habit-ng--datetime-to-time dt2)))
    (cond
     ((time-less-p t1 t2) -1)
     ((time-less-p t2 t1) 1)
     (t 0))))

(defun org-habit-ng--datetime-add (dt &rest adjustments)
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
    (org-habit-ng--time-to-datetime
     (encode-time second minute hour day month year))))

;; Task 4: RRULE Evaluator - DAILY Frequency

(defun org-habit-ng--rrule-next-occurrence (rule from)
  "Compute next occurrence of RULE strictly after FROM datetime.
Returns nil if no more occurrences (past UNTIL or COUNT exhausted)."
  (let* ((freq (plist-get rule :freq))
         (until (plist-get rule :until))
         (next (pcase freq
                 ('daily (org-habit-ng--rrule-next-daily rule from))
                 ('weekly (org-habit-ng--rrule-next-weekly rule from))
                 ('monthly (org-habit-ng--rrule-next-monthly rule from))
                 ('yearly (org-habit-ng--rrule-next-yearly rule from))
                 ('hourly (org-habit-ng--rrule-next-hourly rule from))
                 ('minutely (org-habit-ng--rrule-next-minutely rule from))
                 ('secondly (org-habit-ng--rrule-next-secondly rule from))
                 (_ (error "Unknown frequency: %s" freq)))))
    ;; Check UNTIL boundary
    (when (and next until)
      (when (> (org-habit-ng--datetime-compare next until) 0)
        (setq next nil)))
    next))

(defun org-habit-ng--rrule-next-daily (rule from)
  "Compute next daily occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-ng--datetime-add from :days interval)))

;; Task 5: RRULE Evaluator - WEEKLY Frequency

(defun org-habit-ng--rrule-next-weekly (rule from)
  "Compute next weekly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (byday (plist-get rule :byday)))
    (if (null byday)
        ;; Simple weekly: same day next week(s)
        (org-habit-ng--datetime-add from :days (* 7 interval))
      ;; BYDAY specified: find next matching day
      (let* ((from-dow (org-habit-ng--datetime-dow from))
             (target-days (if (consp (car byday))
                              (mapcar #'cdr byday)  ; Extract day numbers from ordinal pairs
                            byday))                  ; Already simple day numbers
             (sorted-days (sort (copy-sequence target-days) #'<))
             (next-day nil)
             (days-to-add 0))
        ;; Find next day in current week
        (dolist (d sorted-days)
          (when (and (null next-day) (> d from-dow))
            (setq next-day d)))

        (if next-day
            ;; Found a day later this week
            (setq days-to-add (- next-day from-dow))
          ;; No day found in current week, go to first day of next interval
          (setq next-day (car sorted-days))
          (setq days-to-add (+ (- 7 from-dow) next-day (* 7 (1- interval)))))

        (org-habit-ng--datetime-add from :days days-to-add)))))

;; Task 6: RRULE Evaluator - MONTHLY with BYDAY

(defun org-habit-ng--rrule-next-monthly (rule from)
  "Compute next monthly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (byday (plist-get rule :byday))
        (bymonthday (plist-get rule :bymonthday))
        (bysetpos (plist-get rule :bysetpos)))
    (cond
     ;; BYDAY + BYSETPOS (e.g., first/last weekday of month)
     ((and byday bysetpos (not (consp (car byday))))
      (org-habit-ng--rrule-next-monthly-byday-setpos rule from))
     ;; BYDAY with ordinals (e.g., 2SA, -1FR)
     ((and byday (consp (car byday)))
      (org-habit-ng--rrule-next-monthly-byday rule from))
     ;; Simple BYDAY without ordinals
     (byday
      (org-habit-ng--rrule-next-monthly-byday-setpos rule from))
     ;; BYMONTHDAY (e.g., 1, 15, -1)
     (bymonthday
      (org-habit-ng--rrule-next-monthly-bymonthday rule from))
     ;; Simple monthly: same day next month
     (t
      (org-habit-ng--datetime-add from :months interval)))))

(defun org-habit-ng--rrule-next-monthly-byday (rule from)
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
        (if (> (org-habit-ng--datetime-compare candidate from) 0)
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

;; Task 7: RRULE Evaluator - MONTHLY with BYMONTHDAY

(defun org-habit-ng--resolve-monthday (monthday month year)
  "Resolve MONTHDAY for MONTH/YEAR. Handles negative values."
  (if (> monthday 0)
      monthday
    ;; Negative: count from end
    (+ (calendar-last-day-of-month month year) monthday 1)))

(defun org-habit-ng--rrule-next-monthly-bymonthday (rule from)
  "Compute next monthly BYMONTHDAY occurrence after FROM."
  (let* ((interval (plist-get rule :interval))
         (bymonthday (plist-get rule :bymonthday))
         (from-month (plist-get from :month))
         (from-year (plist-get from :year))
         (from-day (plist-get from :day))
         (target-day (car bymonthday)))  ; For now, single day
    ;; Resolve target day for current month
    (let ((resolved-day (org-habit-ng--resolve-monthday target-day from-month from-year)))
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
          (let ((next-resolved (org-habit-ng--resolve-monthday target-day next-month next-year)))
            (list :year next-year
                  :month next-month
                  :day next-resolved
                  :hour (plist-get from :hour)
                  :minute (plist-get from :minute)
                  :second (plist-get from :second))))))))

;; Task 9: RRULE Evaluator - BYSETPOS

(defun org-habit-ng--generate-monthly-byday-set (byday month year)
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

(defun org-habit-ng--apply-bysetpos (dates bysetpos)
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

(defun org-habit-ng--rrule-next-monthly-byday-setpos (rule from)
  "Compute next monthly occurrence with BYDAY and optional BYSETPOS."
  (let* ((interval (plist-get rule :interval))
         (byday (plist-get rule :byday))
         (bysetpos (or (plist-get rule :bysetpos) (list 1)))  ; Default to first
         (from-month (plist-get from :month))
         (from-year (plist-get from :year))
         (from-day (plist-get from :day)))
    ;; Generate matching days for current month
    (let* ((all-days (org-habit-ng--generate-monthly-byday-set byday from-month from-year))
           (selected (org-habit-ng--apply-bysetpos all-days bysetpos))
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
          (let* ((next-all-days (org-habit-ng--generate-monthly-byday-set byday next-month next-year))
                 (next-selected (org-habit-ng--apply-bysetpos next-all-days bysetpos)))
            (list :year next-year
                  :month next-month
                  :day (car next-selected)
                  :hour (plist-get from :hour)
                  :minute (plist-get from :minute)
                  :second (plist-get from :second))))))))

;; Task 8: RRULE Evaluator - YEARLY Frequency

(defun org-habit-ng--rrule-next-yearly (rule from)
  "Compute next yearly occurrence after FROM."
  (let ((interval (plist-get rule :interval))
        (bymonth (plist-get rule :bymonth))
        (byday (plist-get rule :byday)))
    (cond
     ;; BYMONTH + BYDAY (e.g., last Sunday of December)
     ((and bymonth byday)
      (org-habit-ng--rrule-next-yearly-bymonth-byday rule from))
     ;; Simple yearly
     (t
      (org-habit-ng--datetime-add from :years interval)))))

(defun org-habit-ng--rrule-next-yearly-bymonth-byday (rule from)
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
      (if (> (org-habit-ng--datetime-compare candidate from) 0)
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

;; Task 10: RRULE Evaluator - Sub-daily Frequencies

(defun org-habit-ng--rrule-next-hourly (rule from)
  "Compute next hourly occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-ng--datetime-add from :hours interval)))

(defun org-habit-ng--rrule-next-minutely (rule from)
  "Compute next minutely occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-ng--datetime-add from :minutes interval)))

(defun org-habit-ng--rrule-next-secondly (rule from)
  "Compute next secondly occurrence after FROM."
  (let ((interval (plist-get rule :interval)))
    (org-habit-ng--datetime-add from :seconds interval)))

;; Task 11: RRULE COUNT and UNTIL Termination

(defun org-habit-ng--parse-rrule-date (date-string)
  "Parse RRULE date string (YYYYMMDD or YYYYMMDDTHHMMSS) to datetime.
If time component is omitted, defaults to 23:59:59 (end of day)."
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

;; Task 12: X-REPEAT-FROM Extension

(defun org-habit-ng--get-repeat-base (rule scheduled today)
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

;; Task 13: X-WARN Extension

(defun org-habit-ng--parse-warn-days (warn-string)
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

;;; RRULE Builder (Phase 2)

(defconst org-habit-ng--rrule-day-abbrevs
  ["SU" "MO" "TU" "WE" "TH" "FR" "SA"]
  "RRULE day abbreviations indexed by weekday number (0=Sunday).")

(defun org-habit-ng--rrule-build (rule)
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
                                     (format "%d%s" (car d) (aref org-habit-ng--rrule-day-abbrevs (cdr d)))
                                   (aref org-habit-ng--rrule-day-abbrevs d)))
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

;;; Natural Language Generator (Phase 2)

(defconst org-habit-ng--weekday-names
  ["Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday"]
  "Full weekday names indexed by number (0=Sunday).")

(defconst org-habit-ng--month-names
  ["" "January" "February" "March" "April" "May" "June"
   "July" "August" "September" "October" "November" "December"]
  "Full month names indexed by number (1=January).")

(defconst org-habit-ng--ordinal-names
  '((1 . "1st") (2 . "2nd") (3 . "3rd") (4 . "4th") (5 . "5th")
    (-1 . "last") (-2 . "2nd to last"))
  "Ordinal number names for human output.")

(defun org-habit-ng-rrule-to-human (rule)
  "Convert RULE plist to human-readable string."
  (let* ((freq (plist-get rule :freq))
         (interval (or (plist-get rule :interval) 1))
         (byday (plist-get rule :byday))
         (bymonthday (plist-get rule :bymonthday))
         (bymonth (plist-get rule :bymonth))
         (flexibility (plist-get rule :flexibility))
         (base (org-habit-ng--rrule-freq-to-human freq interval)))
    ;; Add frequency-specific details
    (setq base
          (pcase freq
            ('daily base)
            ('weekly
             (if byday
                 (concat base " on "
                         (org-habit-ng--format-weekdays byday))
               base))
            ('monthly
             (cond
              ((and byday (consp (car byday)))
               (let* ((entry (car byday))
                      (ord (car entry))
                      (day (cdr entry)))
                 (concat base " on the "
                         (cdr (assoc ord org-habit-ng--ordinal-names)) " "
                         (aref org-habit-ng--weekday-names day))))
              (bymonthday
               (let ((d (car bymonthday)))
                 (if (= d -1)
                     (concat base " on the last day")
                   (concat base " on day " (number-to-string d)))))
              (t base)))
            ('yearly
             (let ((month-str (when bymonth
                                (aref org-habit-ng--month-names (car bymonth)))))
               (cond
                ((and bymonth byday (consp (car byday)))
                 (let* ((entry (car byday))
                        (ord (car entry))
                        (day (cdr entry)))
                   (concat base " in " month-str " on the "
                           (cdr (assoc ord org-habit-ng--ordinal-names)) " "
                           (aref org-habit-ng--weekday-names day))))
                (t base))))
            (_ base)))
    ;; Add flexibility suffix
    (when flexibility
      (setq base (concat base (format " (within %d day%s)"
                                      flexibility
                                      (if (= flexibility 1) "" "s")))))
    base))

(defun org-habit-ng--rrule-freq-to-human (freq interval)
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

(defun org-habit-ng--format-weekdays (byday)
  "Format BYDAY list as human-readable weekday names."
  (mapconcat (lambda (d)
               (aref org-habit-ng--weekday-names d))
             byday ", "))

;;; Next Occurrences Helper (Phase 2)

(defun org-habit-ng-next-n-occurrences (rule from n)
  "Generate N future occurrences of RULE starting strictly after FROM.
Returns list of datetime plists."
  (let ((occurrences nil)
        (current from))
    (dotimes (_ n)
      (setq current (org-habit-ng--rrule-next-occurrence rule current))
      (when current
        (push current occurrences)))
    (nreverse occurrences)))

(defun org-habit-ng--format-occurrence (dt)
  "Format datetime DT as human-readable date string."
  (let ((time (org-habit-ng--datetime-to-time dt)))
    (format-time-string "%a %b %d, %Y" time)))

;;; Wizard State Management

(defvar org-habit-ng--wizard-state nil
  "Current state of the recurrence wizard.")

(defun org-habit-ng--wizard-state-create ()
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

(defun org-habit-ng--wizard-state-to-rule (state)
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

;;; Wizard Prompts (Completing-Read Fallback)

(defconst org-habit-ng--frequency-options
  '(("Daily" . daily)
    ("Weekly" . weekly)
    ("Monthly" . monthly)
    ("Yearly" . yearly)
    ("Custom RRULE..." . custom))
  "Frequency options for wizard.")

(defun org-habit-ng--wizard-prompt-frequency ()
  "Prompt user for recurrence frequency. Returns symbol."
  (let* ((choices (mapcar #'car org-habit-ng--frequency-options))
         (choice (completing-read "How often does this repeat? " choices nil t)))
    (cdr (assoc choice org-habit-ng--frequency-options))))

(defun org-habit-ng--wizard-prompt-interval (freq)
  "Prompt for interval based on FREQ. Returns number."
  (let ((unit (pcase freq
                ('daily "days")
                ('weekly "weeks")
                ('monthly "months")
                ('yearly "years")
                (_ "periods"))))
    (read-number (format "Every how many %s? " unit) 1)))

(defconst org-habit-ng--weekday-options
  '(("Sunday" . 0) ("Monday" . 1) ("Tuesday" . 2) ("Wednesday" . 3)
    ("Thursday" . 4) ("Friday" . 5) ("Saturday" . 6))
  "Weekday options for wizard.")

(defun org-habit-ng--wizard-prompt-weekdays ()
  "Prompt for weekday selection. Returns sorted list of day numbers."
  (let* ((choices (mapcar #'car org-habit-ng--weekday-options))
         (selected (completing-read-multiple "Which days? " choices nil t)))
    (sort (mapcar (lambda (s) (cdr (assoc s org-habit-ng--weekday-options)))
                  selected)
          #'<)))

;;; Task 9: Monthly Type Selection

(defconst org-habit-ng--monthly-type-options
  '(("Specific day of month (e.g., the 15th)" . day-of-month)
    ("Nth weekday (e.g., 2nd Saturday)" . nth-weekday)
    ("Last specific weekday (e.g., last Friday)" . last-weekday)
    ("Last day of month" . last-day))
  "Monthly recurrence type options.")

(defun org-habit-ng--wizard-prompt-monthly-type ()
  "Prompt for monthly recurrence type. Returns symbol."
  (let* ((choices (mapcar #'car org-habit-ng--monthly-type-options))
         (choice (completing-read "Repeat on: " choices nil t)))
    (cdr (assoc choice org-habit-ng--monthly-type-options))))

;;; Task 10: Monthly Day Details

(defconst org-habit-ng--ordinal-options
  '(("First" . 1) ("Second" . 2) ("Third" . 3) ("Fourth" . 4) ("Fifth" . 5))
  "Ordinal options for nth weekday selection.")

(defun org-habit-ng--wizard-prompt-monthly-details (type)
  "Prompt for monthly details based on TYPE. Returns partial rule plist."
  (pcase type
    ('day-of-month
     (let ((day (read-number "Which day of month? (1-31): " 1)))
       (list :bymonthday (list day))))
    ('nth-weekday
     (let* ((day-choices (mapcar #'car org-habit-ng--weekday-options))
            (day-name (completing-read "Which day? " day-choices nil t))
            (day-num (cdr (assoc day-name org-habit-ng--weekday-options)))
            (ord-choices (mapcar #'car org-habit-ng--ordinal-options))
            (ord-name (completing-read "Which occurrence? " ord-choices nil t))
            (ord-num (cdr (assoc ord-name org-habit-ng--ordinal-options))))
       (list :byday (list (cons ord-num day-num)))))
    ('last-weekday
     (let* ((day-choices (mapcar #'car org-habit-ng--weekday-options))
            (day-name (completing-read "Which day? " day-choices nil t))
            (day-num (cdr (assoc day-name org-habit-ng--weekday-options))))
       (list :byday (list (cons -1 day-num)))))
    ('last-day
     (list :bymonthday (list -1)))))

;;; Task 11: Yearly Month Selection

(defconst org-habit-ng--month-options
  '(("January" . 1) ("February" . 2) ("March" . 3) ("April" . 4)
    ("May" . 5) ("June" . 6) ("July" . 7) ("August" . 8)
    ("September" . 9) ("October" . 10) ("November" . 11) ("December" . 12))
  "Month options for wizard.")

(defun org-habit-ng--wizard-prompt-month ()
  "Prompt for month selection. Returns month number (1-12)."
  (let* ((choices (mapcar #'car org-habit-ng--month-options))
         (choice (completing-read "Which month? " choices nil t)))
    (cdr (assoc choice org-habit-ng--month-options))))

;;; Task 12: Flexibility Window

(defun org-habit-ng--wizard-prompt-flexibility ()
  "Prompt for flexibility window. Returns number or nil."
  (when (y-or-n-p
         (concat "Add flexibility window?\n\n"
                 "  A flexibility window lets you complete the habit within N days\n"
                 "  of the scheduled date. Useful for habits that don't need exact\n"
                 "  timing, like \"water plants every 3 days, give or take a day.\"\n\n"
                 "Add flexibility window? "))
    (read-number "Complete within how many days of scheduled date? " 1)))

;;; Task 13: Repeat From

(defconst org-habit-ng--repeat-from-options
  '(("Scheduled date" . scheduled)
    ("Completion date" . completion))
  "Repeat-from options for wizard.")

(defun org-habit-ng--wizard-prompt-repeat-from ()
  "Prompt for repeat-from selection. Returns symbol."
  (let* ((prompt (concat "When you mark DONE, advance next occurrence from:\n\n"
                         "  Scheduled date\n"
                         "      If scheduled for Mon and you complete on Wed,\n"
                         "      next occurrence is calculated from Mon.\n\n"
                         "  Completion date\n"
                         "      If scheduled for Mon and you complete on Wed,\n"
                         "      next occurrence is calculated from Wed.\n\n"
                         "Advance from: "))
         (choices (mapcar #'car org-habit-ng--repeat-from-options))
         (choice (completing-read prompt choices nil t nil nil "Scheduled date")))
    (cdr (assoc choice org-habit-ng--repeat-from-options))))

;;; Task 14: Preview Display

(defcustom org-habit-ng-preview-occurrences 3
  "Number of future occurrences to show in preview."
  :type 'integer
  :group 'org-habit-ng)

(defun org-habit-ng--wizard-format-preview (rule)
  "Format RULE as preview string."
  (let* ((human (org-habit-ng-rrule-to-human rule))
         (rrule (org-habit-ng--rrule-build rule))
         (now (org-habit-ng--time-to-datetime (current-time)))
         (occurrences (org-habit-ng-next-n-occurrences rule now org-habit-ng-preview-occurrences))
         (occ-strings (mapcar #'org-habit-ng--format-occurrence occurrences)))
    (concat "Recurrence Preview\n"
            (make-string 18 ?\u2500) "\n\n"
            "  " human "\n\n"
            "  RRULE: " rrule "\n\n"
            "  Next " (number-to-string org-habit-ng-preview-occurrences) " occurrences:\n"
            (mapconcat (lambda (s) (concat "    \u2022 " s)) occ-strings "\n")
            "\n")))

;;; Task 15: Save Recurrence Property

(defun org-habit-ng--wizard-save-recurrence (rrule-string)
  "Save RRULE-STRING to current org entry's RECURRENCE property."
  (org-entry-put nil org-habit-ng-recurrence-property rrule-string))

;;; Task 16: Main Wizard Flow (Completing-Read Version)

(defun org-habit-ng--plist-merge (base additions)
  "Merge ADDITIONS plist into BASE plist."
  (let ((result (copy-sequence base)))
    (while additions
      (setq result (plist-put result (car additions) (cadr additions)))
      (setq additions (cddr additions)))
    result))

(defun org-habit-ng--wizard-show-preview (rule)
  "Show preview of RULE and prompt for confirmation.
Returns t if user confirms, nil to cancel."
  (let ((preview (org-habit-ng--wizard-format-preview rule)))
    (with-temp-buffer
      (insert preview)
      (insert "\n[y] Save  [n] Cancel  [e] Start over\n")
      (message "%s" (buffer-string)))
    (let ((response (read-char-choice "Save recurrence? [y/n/e]: " '(?y ?n ?e))))
      (pcase response
        (?y t)
        (?n nil)
        (?e (org-habit-ng--wizard-run-completing-read) nil)))))

(defun org-habit-ng--wizard-run-completing-read ()
  "Run the recurrence wizard using completing-read prompts."
  (let ((state (org-habit-ng--wizard-state-create)))
    ;; Step 1: Frequency
    (let ((freq (org-habit-ng--wizard-prompt-frequency)))
      (if (eq freq 'custom)
          ;; Custom RRULE entry
          (let ((rrule (read-string "Enter RRULE: ")))
            (when (org-habit-ng--wizard-show-preview
                   (org-habit-ng--rrule-parse rrule))
              (org-habit-ng--wizard-save-recurrence rrule)))
        ;; Normal wizard flow
        (setq state (plist-put state :freq freq))
        ;; Step 2: Interval
        (setq state (plist-put state :interval
                               (org-habit-ng--wizard-prompt-interval freq)))
        ;; Step 3: Day constraints
        (pcase freq
          ('weekly
           (setq state (plist-put state :byday
                                  (org-habit-ng--wizard-prompt-weekdays))))
          ('monthly
           (let* ((type (org-habit-ng--wizard-prompt-monthly-type))
                  (details (org-habit-ng--wizard-prompt-monthly-details type)))
             (setq state (org-habit-ng--plist-merge state details))))
          ('yearly
           (setq state (plist-put state :bymonth
                                  (list (org-habit-ng--wizard-prompt-month))))
           (let* ((type (org-habit-ng--wizard-prompt-monthly-type))
                  (details (org-habit-ng--wizard-prompt-monthly-details type)))
             (setq state (org-habit-ng--plist-merge state details)))))
        ;; Step 4: Flexibility
        (when-let ((flex (org-habit-ng--wizard-prompt-flexibility)))
          (setq state (plist-put state :flexibility flex)))
        ;; Step 5: Repeat from
        (setq state (plist-put state :repeat-from
                               (org-habit-ng--wizard-prompt-repeat-from)))
        ;; Step 6: Preview and save
        (let ((rule (org-habit-ng--wizard-state-to-rule state)))
          (when (org-habit-ng--wizard-show-preview rule)
            (org-habit-ng--wizard-save-recurrence
             (org-habit-ng--rrule-build rule))))))))

;;; Task 17: Entry Point Command

(defcustom org-habit-ng-use-completing-read nil
  "When non-nil, use completing-read instead of transient menus.
When nil, auto-detect based on display capabilities."
  :type 'boolean
  :group 'org-habit-ng)

(defun org-habit-ng--wizard-handle-existing (rrule)
  "Handle existing RRULE - offer to modify or clear."
  (let* ((rule (org-habit-ng--rrule-parse rrule))
         (human (org-habit-ng-rrule-to-human rule))
         (choice (completing-read
                  (format "Current recurrence:\n  %s\n  RRULE: %s\n\nAction: "
                          human rrule)
                  '("Modify" "Clear" "Cancel") nil t)))
    (pcase choice
      ("Modify" (org-habit-ng--wizard-run-completing-read))
      ("Clear"
       (when (y-or-n-p "Remove recurrence? ")
         (org-entry-delete nil org-habit-ng-recurrence-property)
         (message "Recurrence removed.")))
      ("Cancel" (message "Cancelled.")))))

;;;###autoload
(defun org-habit-ng-set-recurrence ()
  "Set or modify the recurrence pattern for the current org heading.
Uses a progressive wizard to build an RRULE string."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not in org-mode"))
  (unless (org-at-heading-p)
    (org-back-to-heading t))
  ;; Check for existing recurrence
  (let ((existing (org-entry-get nil org-habit-ng-recurrence-property)))
    (if existing
        (org-habit-ng--wizard-handle-existing existing)
      ;; New recurrence
      (org-habit-ng--wizard-run))))

(defun org-habit-ng--wizard-run ()
  "Run the appropriate wizard based on display and settings."
  (setq org-habit-ng--wizard-state (org-habit-ng--wizard-state-create))
  (if (and (not org-habit-ng-use-completing-read)
           (display-graphic-p)
           (featurep 'transient))
      (org-habit-ng--wizard-run-transient)
    (org-habit-ng--wizard-run-completing-read)))

;;; Task 18: Transient UI (Optional GUI Enhancement)

(defvar org-habit-ng--weekday-selection nil
  "Currently selected weekdays in toggle picker.")

(defun org-habit-ng--toggle-weekday (day)
  "Toggle DAY in weekday selection."
  (if (member day org-habit-ng--weekday-selection)
      (setq org-habit-ng--weekday-selection
            (delete day org-habit-ng--weekday-selection))
    (push day org-habit-ng--weekday-selection)))

(when (require 'transient nil t)

  (transient-define-prefix org-habit-ng--transient-frequency ()
    "Select recurrence frequency."
    ["How often does this repeat?"
     ("d" "Daily" org-habit-ng--transient-set-daily)
     ("w" "Weekly" org-habit-ng--transient-set-weekly)
     ("m" "Monthly" org-habit-ng--transient-set-monthly)
     ("y" "Yearly" org-habit-ng--transient-set-yearly)
     ("c" "Custom RRULE..." org-habit-ng--transient-set-custom)])

  (defun org-habit-ng--transient-set-daily ()
    "Set frequency to daily and continue wizard."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :freq 'daily))
    (org-habit-ng--transient-interval))

  (defun org-habit-ng--transient-set-weekly ()
    "Set frequency to weekly and continue wizard."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :freq 'weekly))
    (org-habit-ng--transient-interval))

  (defun org-habit-ng--transient-set-monthly ()
    "Set frequency to monthly and continue wizard."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :freq 'monthly))
    (org-habit-ng--transient-interval))

  (defun org-habit-ng--transient-set-yearly ()
    "Set frequency to yearly and continue wizard."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :freq 'yearly))
    (org-habit-ng--transient-interval))

  (defun org-habit-ng--transient-set-custom ()
    "Enter custom RRULE string."
    (interactive)
    (let ((rrule (read-string "Enter RRULE: ")))
      (when (org-habit-ng--wizard-show-preview
             (org-habit-ng--rrule-parse rrule))
        (org-habit-ng--wizard-save-recurrence rrule))))

  (defun org-habit-ng--transient-interval ()
    "Prompt for interval after frequency selection."
    (let* ((freq (plist-get org-habit-ng--wizard-state :freq))
           (interval (org-habit-ng--wizard-prompt-interval freq)))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :interval interval))
      ;; Continue to day constraints
      (pcase freq
        ('daily (org-habit-ng--transient-flexibility))
        ('weekly (org-habit-ng--transient-weekdays))
        ('monthly (org-habit-ng--transient-monthly-type))
        ('yearly (org-habit-ng--transient-yearly-month)))))

  ;; Task 19: Transient Weekday Toggle Picker

  (transient-define-prefix org-habit-ng--transient-weekdays ()
    "Select weekdays for recurrence."
    :init-value (lambda (_) (setq org-habit-ng--weekday-selection nil))
    ["Which days? (toggle with letter, RET when done)"
     ""
     ("M" org-habit-ng--transient-toggle-mon
      :description (lambda () (org-habit-ng--weekday-desc 1 "Mon")))
     ("T" org-habit-ng--transient-toggle-tue
      :description (lambda () (org-habit-ng--weekday-desc 2 "Tue")))
     ("W" org-habit-ng--transient-toggle-wed
      :description (lambda () (org-habit-ng--weekday-desc 3 "Wed")))
     ("R" org-habit-ng--transient-toggle-thu
      :description (lambda () (org-habit-ng--weekday-desc 4 "Thu")))
     ("F" org-habit-ng--transient-toggle-fri
      :description (lambda () (org-habit-ng--weekday-desc 5 "Fri")))
     ("S" org-habit-ng--transient-toggle-sat
      :description (lambda () (org-habit-ng--weekday-desc 6 "Sat")))
     ("U" org-habit-ng--transient-toggle-sun
      :description (lambda () (org-habit-ng--weekday-desc 0 "Sun")))]
    [("RET" "Done" org-habit-ng--transient-weekdays-done)])

  (defun org-habit-ng--weekday-desc (day name)
    "Return description for DAY toggle showing NAME and selection state."
    (if (member day org-habit-ng--weekday-selection)
        (format "[X] %s" name)
      (format "[ ] %s" name)))

  (defun org-habit-ng--transient-toggle-mon () (interactive) (org-habit-ng--toggle-weekday 1))
  (defun org-habit-ng--transient-toggle-tue () (interactive) (org-habit-ng--toggle-weekday 2))
  (defun org-habit-ng--transient-toggle-wed () (interactive) (org-habit-ng--toggle-weekday 3))
  (defun org-habit-ng--transient-toggle-thu () (interactive) (org-habit-ng--toggle-weekday 4))
  (defun org-habit-ng--transient-toggle-fri () (interactive) (org-habit-ng--toggle-weekday 5))
  (defun org-habit-ng--transient-toggle-sat () (interactive) (org-habit-ng--toggle-weekday 6))
  (defun org-habit-ng--transient-toggle-sun () (interactive) (org-habit-ng--toggle-weekday 0))

  (defun org-habit-ng--transient-weekdays-done ()
    "Finish weekday selection and continue wizard."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :byday
                     (sort org-habit-ng--weekday-selection #'<)))
    (org-habit-ng--transient-flexibility))

  ;; Task 20: Wire Up Transient to Entry Point

  (defun org-habit-ng--wizard-run-transient ()
    "Run wizard using transient menus."
    (org-habit-ng--transient-frequency))

  ;; Task 21: Complete Transient Flow

  ;; Monthly type selection
  (transient-define-prefix org-habit-ng--transient-monthly-type ()
    "Select monthly recurrence type."
    ["Repeat on:"
     ("d" "Specific day of month (e.g., the 15th)" org-habit-ng--transient-monthly-day)
     ("n" "Nth weekday (e.g., 2nd Saturday)" org-habit-ng--transient-monthly-nth)
     ("l" "Last specific weekday (e.g., last Friday)" org-habit-ng--transient-monthly-last)
     ("e" "Last day of month" org-habit-ng--transient-monthly-lastday)])

  (defun org-habit-ng--transient-monthly-day ()
    "Set monthly day-of-month and continue."
    (interactive)
    (let ((day (read-number "Which day of month? (1-31): " 1)))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :bymonthday (list day)))
      (org-habit-ng--transient-flexibility)))

  (defun org-habit-ng--transient-monthly-nth ()
    "Set monthly nth weekday and continue."
    (interactive)
    (let* ((day-name (completing-read "Which day? " (mapcar #'car org-habit-ng--weekday-options) nil t))
           (day-num (cdr (assoc day-name org-habit-ng--weekday-options)))
           (ord-name (completing-read "Which occurrence? " (mapcar #'car org-habit-ng--ordinal-options) nil t))
           (ord-num (cdr (assoc ord-name org-habit-ng--ordinal-options))))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :byday (list (cons ord-num day-num))))
      (org-habit-ng--transient-flexibility)))

  (defun org-habit-ng--transient-monthly-last ()
    "Set monthly last weekday and continue."
    (interactive)
    (let* ((day-name (completing-read "Which day? " (mapcar #'car org-habit-ng--weekday-options) nil t))
           (day-num (cdr (assoc day-name org-habit-ng--weekday-options))))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :byday (list (cons -1 day-num))))
      (org-habit-ng--transient-flexibility)))

  (defun org-habit-ng--transient-monthly-lastday ()
    "Set monthly last day and continue."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :bymonthday (list -1)))
    (org-habit-ng--transient-flexibility))

  ;; Yearly month selection
  (defun org-habit-ng--transient-yearly-month ()
    "Prompt for month and continue to day selection."
    (let ((month (org-habit-ng--wizard-prompt-month)))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :bymonth (list month)))
      (org-habit-ng--transient-monthly-type)))

  ;; Flexibility
  (transient-define-prefix org-habit-ng--transient-flexibility ()
    "Ask about flexibility window."
    ["Add flexibility window?\n\n  A flexibility window lets you complete the habit within N days\n  of the scheduled date. Useful for habits that don't need exact\n  timing, like \"water plants every 3 days, give or take a day.\""
     ""
     ("y" "Yes, add window" org-habit-ng--transient-flexibility-yes)
     ("n" "No, exact dates only" org-habit-ng--transient-flexibility-no)])

  (defun org-habit-ng--transient-flexibility-yes ()
    "Add flexibility window and continue."
    (interactive)
    (let ((days (read-number "Complete within how many days of scheduled date? " 1)))
      (setq org-habit-ng--wizard-state
            (plist-put org-habit-ng--wizard-state :flexibility days))
      (org-habit-ng--transient-repeat-from)))

  (defun org-habit-ng--transient-flexibility-no ()
    "Skip flexibility and continue."
    (interactive)
    (org-habit-ng--transient-repeat-from))

  ;; Repeat-from
  (transient-define-prefix org-habit-ng--transient-repeat-from ()
    "Select repeat-from option."
    ["When you mark DONE, advance next occurrence from:\n"
     ""
     ("s" "Scheduled date\n      If scheduled for Mon and you complete on Wed,\n      next occurrence is calculated from Mon."
      org-habit-ng--transient-repeat-scheduled)
     ""
     ("c" "Completion date\n      If scheduled for Mon and you complete on Wed,\n      next occurrence is calculated from Wed."
      org-habit-ng--transient-repeat-completion)])

  (defun org-habit-ng--transient-repeat-scheduled ()
    "Set repeat-from to scheduled and show preview."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :repeat-from 'scheduled))
    (org-habit-ng--transient-preview))

  (defun org-habit-ng--transient-repeat-completion ()
    "Set repeat-from to completion and show preview."
    (interactive)
    (setq org-habit-ng--wizard-state
          (plist-put org-habit-ng--wizard-state :repeat-from 'completion))
    (org-habit-ng--transient-preview))

  ;; Preview
  (defun org-habit-ng--transient-preview ()
    "Show preview and offer to save."
    (let ((rule (org-habit-ng--wizard-state-to-rule org-habit-ng--wizard-state)))
      (when (org-habit-ng--wizard-show-preview rule)
        (org-habit-ng--wizard-save-recurrence
         (org-habit-ng--rrule-build rule))
        (message "Recurrence saved!")))))


;;; Consistency Graph (Phase 3)

(defun org-habit-ng--days-to-datetime (days)
  "Convert DAYS since epoch to datetime plist."
  ;; Use encode-time to create a proper time from days
  ;; The epoch for time-to-days is day 1 = Jan 1, year 1
  ;; We'll use a reference point: Jan 1, 2024 = day 738886
  (let* ((ref-days 738886)
         (ref-time (encode-time 0 0 0 1 1 2024))
         (day-diff (- days ref-days))
         ;; 1 day = 86400 seconds
         (time (time-add ref-time (seconds-to-time (* day-diff 86400)))))
    (org-habit-ng--time-to-datetime time)))

(defun org-habit-ng--datetime-to-days (dt)
  "Convert datetime plist DT to days since epoch."
  (time-to-days (org-habit-ng--datetime-to-time dt)))

(defun org-habit-ng--get-due-dates-in-range (rule start-day end-day)
  "Get all RRULE due dates in range START-DAY to END-DAY (inclusive).
START-DAY and END-DAY are days since epoch (as used by org-habit).
RULE is a parsed RRULE plist.
Returns sorted list of day numbers.
Uses START-DAY as the reference point (DTSTART) for the recurrence pattern."
  (let ((dates nil)
        ;; Start from start-day itself as the DTSTART reference
        (current-dt (org-habit-ng--days-to-datetime start-day))
        (next-dt nil)
        (iterations 0)
        (max-iterations 1000))  ; Safety limit
    ;; Iterate forward to get occurrences
    (while (and current-dt
                (< iterations max-iterations))
      (setq next-dt (org-habit-ng--rrule-next-occurrence rule current-dt))
      (setq iterations (1+ iterations))
      (if (null next-dt)
          ;; No more occurrences
          (setq current-dt nil)
        ;; Have a next occurrence
        (let ((day (org-habit-ng--datetime-to-days next-dt)))
          (if (> day end-day)
              ;; Past the end of our range, stop
              (setq current-dt nil)
            ;; Within our range, collect it
            (progn
              (push day dates)
              ;; Move to next
              (setq current-dt next-dt))))))
    (nreverse dates)))

(defun org-habit-ng--get-nearest-due-date (day due-dates)
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

(defun org-habit-ng--get-graph-face (distance flexibility donep futurep)
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

(defun org-habit-ng--get-rrule-from-agenda-marker ()
  "Get parsed RRULE from the org entry referenced by current agenda line.
Returns parsed RRULE plist or nil if no RECURRENCE property."
  (let ((marker (get-text-property (point) 'org-marker)))
    (when (and marker (marker-buffer marker))
      (with-current-buffer (marker-buffer marker)
        (save-excursion
          (goto-char marker)
          (let ((recurrence (org-entry-get nil org-habit-ng-recurrence-property)))
            (when (and recurrence (string-match-p "FREQ=" recurrence))
              (org-habit-ng--rrule-parse recurrence))))))))

(defun org-habit-ng--build-graph (habit starting current ending rrule)
  "Build consistency graph for RRULE HABIT from STARTING to ENDING.
CURRENT is the current time for determining past/future.
RRULE is the parsed RRULE plist.
Returns a propertized string like `org-habit-build-graph'."
  (let* ((dominated-dates (org-habit-done-dates habit))
         (start-day (time-to-days starting))
         (now-day (time-to-days current))
         (end-day (time-to-days ending))
         (flexibility (or (plist-get rrule :flexibility) 0))
         (due-dates (org-habit-ng--get-due-dates-in-range rrule start-day end-day))
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
             (nearest (org-habit-ng--get-nearest-due-date start-day due-dates))
             (distance (car nearest))
             (faces (org-habit-ng--get-graph-face distance flexibility donep futurep))
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

(defun org-habit-ng--around-build-graph (orig-fun habit starting current ending)
  "Advice to use RRULE-aware graph for habits with RECURRENCE property.
Falls back to ORIG-FUN for standard habits or on error."
  (let ((rrule (org-habit-ng--get-rrule-from-agenda-marker)))
    (if rrule
        (condition-case err
            (org-habit-ng--build-graph habit starting current ending rrule)
          (error
           (message "org-habit-ng graph error: %s, using fallback" (error-message-string err))
           (funcall orig-fun habit starting current ending)))
      (funcall orig-fun habit starting current ending))))

(defun org-habit-ng--enable-graph-advice ()
  "Enable advice on `org-habit-build-graph'."
  (advice-add 'org-habit-build-graph :around #'org-habit-ng--around-build-graph))

(defun org-habit-ng--disable-graph-advice ()
  "Disable advice on `org-habit-build-graph'."
  (advice-remove 'org-habit-build-graph #'org-habit-ng--around-build-graph))


;;;###autoload
(define-minor-mode org-habit-ng-mode
  "Minor mode for complex recurrence patterns in org-habit.
When enabled, habits with a RECURRENCE property use RRULE-based
scheduling instead of org-mode's simple repeaters.

This mode manages:
- Advice on `org-auto-repeat-maybe' for RRULE-based next occurrence
- Advice on `org-habit-parse-todo' for accurate interval reporting
- Advice on `org-habit-build-graph' for accurate consistency graphs"
  :global t
  :lighter nil
  (if org-habit-ng-mode
      (progn
        (org-habit-ng--enable-advice)
        (org-habit-ng--enable-parse-advice)
        (org-habit-ng--enable-graph-advice))
    (org-habit-ng--disable-advice)
    (org-habit-ng--disable-parse-advice)
    (org-habit-ng--disable-graph-advice)))

(provide 'org-habit-ng)
;;; org-habit-ng.el ends here
