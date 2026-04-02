# Remove Repeater Requirement When RECURRENCE Exists

## Summary

Allow habits with RECURRENCE property to omit the org repeater (e.g., `.+1m`) from the SCHEDULED timestamp. Currently required for org-habit compatibility, but org-habit-ng can build its own habit structure.

## Current vs Desired

**Current (repeater required):**
```org
* TODO Monthly review
SCHEDULED: <2024-01-13 Sat .+1m>
:PROPERTIES:
:STYLE: habit
:RECURRENCE: FREQ=MONTHLY;BYDAY=2SA
:END:
```

**Desired (repeater optional):**
```org
* TODO Monthly review
SCHEDULED: <2024-01-13 Sat>
:PROPERTIES:
:STYLE: habit
:RECURRENCE: FREQ=MONTHLY;BYDAY=2SA
:END:
```

## Design

### Modified: `--around-parse-todo`

Change from "call orig-fun, then modify" to "check first, maybe bypass":

```elisp
(defun org-habit-ng--around-parse-todo (orig-fun &optional pom)
  (save-excursion
    (when pom (goto-char pom))
    (let ((recurrence (org-habit-ng--get-recurrence)))
      (if recurrence
          ;; Build synthetic habit structure ourselves
          (org-habit-ng--build-habit-struct recurrence pom)
        ;; No RECURRENCE — use original org-habit behavior
        (funcall orig-fun pom)))))
```

### New: `--build-habit-struct`

Builds the 6-element habit structure from RRULE:

```elisp
(defun org-habit-ng--build-habit-struct (rule pom)
  "Build habit structure from RRULE at POM."
  (save-excursion
    (when pom (goto-char pom))
    (let* ((scheduled (org-get-scheduled-time (point)))
           (scheduled-days (and scheduled (time-to-days scheduled)))
           (interval (org-habit-ng--approximate-interval rule))
           (repeat-from (or (plist-get rule :repeat-from) 'completion))
           (repeater-type (if (eq repeat-from 'completion) ".+" "++"))
           (closed-dates (org-habit-ng--get-closed-dates)))
      (unless scheduled-days
        (error "Habit '%s' has no scheduled date"
               (org-get-heading t t t t)))
      (list scheduled-days    ; 0: scheduled
            interval          ; 1: repeat interval
            nil               ; 2: deadline (not used)
            nil               ; 3: deadline repeat (not used)
            closed-dates      ; 4: past completion dates
            repeater-type)))) ; 5: repeater type
```

### New: `--get-closed-dates`

Extracted from `org-habit-parse-todo` — searches logbook for DONE state changes:

```elisp
(defun org-habit-ng--get-closed-dates ()
  "Extract past DONE dates from current heading's logbook.
Returns list of days-since-epoch, most recent first."
  ;; ... (see org-habit-parse-todo lines 215-241 for logic)
```

### Repeater Type Mapping

- `X-REPEAT-FROM=completion` (or absent) → `".+"`
- `X-REPEAT-FROM=scheduled` or `scheduled-future` → `"++"`

## Changes Required

1. Add `org-habit-ng--get-closed-dates` function
2. Add `org-habit-ng--build-habit-struct` function
3. Modify `org-habit-ng--around-parse-todo` to check RECURRENCE first
4. Update README examples to remove `.+1m` repeaters
5. Add tests for habits without repeaters
