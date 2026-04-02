# Stale DONE Recovery - Design Document

**Goal:** Detect and repair habits that were marked DONE on mobile apps but never advanced to the next occurrence.

**Architecture:** Detection on agenda build (togglable) plus batch command. Direct state repair without simulating org-todo flow.

**Tech Stack:** org-habit-plus, LOGBOOK parsing, completing-read for user prompts

---

## Problem Statement

When a habit is marked DONE on a mobile app (Orgzly, Beorg, etc.), the app typically:
1. Changes state from TODO → DONE
2. Does NOT run `org-auto-repeat-maybe` (elisp hooks don't exist)
3. Does NOT advance SCHEDULED to next occurrence

Result: Habit syncs back as "stale DONE" - frozen in completed state with outdated SCHEDULED.

## Detection

### What is "stale"?

A habit is stale if:
- State is DONE (or any done-state from `org-done-keywords`)
- Entry has a repeater in SCHEDULED (`.+`, `+`, or `++`)
- Entry has `:STYLE: habit` property

Note: SCHEDULED being in past OR future doesn't matter. A repeating habit in DONE state is inherently broken - the DONE→TODO reset should have happened.

### Detection Modes

**1. Agenda auto-detect (togglable, default off)**

When building agenda, scan for stale habits. For each one found, prompt:
```
Habit "Morning meditation" is stuck in DONE state.
Fix and advance to next occurrence? [y/n]
```

Controlled by:
```elisp
(defcustom org-habit-plus-detect-stale-on-agenda nil
  "When non-nil, detect stale DONE habits when building agenda."
  :type 'boolean
  :group 'org-habit-plus)
```

**2. Batch command: `M-x org-habit-plus-fix-stale`**

Scans all agenda files for stale habits. Behavior controlled by:
```elisp
(defcustom org-habit-plus-batch-fix-mode 'review
  "How to handle multiple stale habits in batch fix.
`silent' - fix all without prompting
`review' - show buffer listing stale habits, user selects which to fix"
  :type '(choice (const :tag "Silent fix all" silent)
                 (const :tag "Review buffer" review))
  :group 'org-habit-plus)
```

## Determining Completion Date

The fix needs to know when the habit was completed to compute the next occurrence correctly.

### Priority order:

1. **Parse LOGBOOK** - Look for state change entries:
   ```
   - State "DONE" from "TODO" [2024-01-15 Mon 10:30]
   ```

2. **Multiple entries** - If multiple DONE entries found since SCHEDULED date:
   - Use most recent completion date
   - Inform user: "Found 5 completions since last sync. Advancing from most recent (Jan 19)."

3. **No LOGBOOK entry** - Prompt user:
   ```
   No completion date found for "Morning meditation".
   When was it completed?

     [t] Today
     [s] Original scheduled date (2024-01-15)
     [e] Enter specific date
   ```

## Fix Operation

Once completion date is determined:

1. **Compute next occurrence** using RRULE engine
   - Respects `X-REPEAT-FROM` (scheduled vs completion)
   - If `X-REPEAT-FROM=completion`: use determined completion date
   - If `X-REPEAT-FROM=scheduled`: use original SCHEDULED date

2. **Update SCHEDULED** to next occurrence
   - Preserve repeater syntax (`.+1w` etc.) for mobile app compatibility

3. **Reset state** to TODO (or `REPEAT_TO_STATE` if set)
   - Direct state change, not via `org-todo`
   - Avoids spurious LOGBOOK entries like "State TODO from DONE"

4. **Do NOT modify LOGBOOK**
   - The completion already happened and was (maybe) logged
   - We're repairing, not completing

## Core Functions

| Function | Purpose |
|----------|---------|
| `org-habit-plus-stale-p` | Predicate: is this entry a stale DONE habit? |
| `org-habit-plus--get-completion-date` | Parse LOGBOOK for most recent DONE timestamp |
| `org-habit-plus--prompt-completion-date` | Ask user when LOGBOOK has no entry |
| `org-habit-plus-fix-stale-at-point` | Fix stale habit at point |
| `org-habit-plus-fix-stale` | Batch command for all agenda files |
| `org-habit-plus--stale-review-buffer` | Buffer UI for reviewing/selecting stale habits |

## Agenda Hook Integration

```elisp
(defun org-habit-plus--check-stale-on-agenda ()
  "Check for stale habits after agenda is built."
  (when org-habit-plus-detect-stale-on-agenda
    (save-excursion
      (goto-char (point-min))
      (while (org-habit-plus--next-stale-in-agenda)
        (org-habit-plus--prompt-fix-stale)))))

;; Hook into agenda finalization
(add-hook 'org-agenda-finalize-hook #'org-habit-plus--check-stale-on-agenda)
```

## User Flow Examples

### Single stale habit on agenda open

```
Building agenda...

Habit "Weekly review" is stuck in DONE state.
Found 1 completion: [2024-01-14 Sun]
Fix and advance to next occurrence (2024-01-21)? [y/n] y

Agenda for week of January 15, 2024
...
```

### Batch review mode

```
M-x org-habit-plus-fix-stale

Found 3 stale habits:

[ ] Morning meditation
    DONE since: [2024-01-18 Thu]
    SCHEDULED: <2024-01-15 Mon .+1d>
    Next occurrence: <2024-01-19 Fri>

[ ] Weekly review
    DONE since: [2024-01-14 Sun]
    SCHEDULED: <2024-01-08 Mon .+1w>
    Next occurrence: <2024-01-21 Sun>

[x] Exercise (no LOGBOOK - will prompt for date)
    SCHEDULED: <2024-01-10 Wed .+2d>

[f] Fix selected  [a] Fix all  [q] Quit
```

## Edge Cases

| Situation | Handling |
|-----------|----------|
| SCHEDULED in future, state DONE | Still flag as stale. Reset to TODO, keep future SCHEDULED. |
| Multiple LOGBOOK completions | Use most recent, inform user of count |
| No LOGBOOK entry | Prompt user: Today / Original date / Enter date |
| RRULE has expired (UNTIL/COUNT) | Compute returns nil; inform user habit has ended |
| Malformed RECURRENCE property | Skip with warning, don't break batch operation |
| Entry has DEADLINE with repeater | Update DEADLINE too (same offset from SCHEDULED) |

## Testing Approach

**Unit tests:**
- `org-habit-plus-stale-p` - various state/repeater combinations
- `org-habit-plus--get-completion-date` - LOGBOOK parsing
- Fix operation - state reset, SCHEDULED update

**Integration tests:**
- Full flow: stale detection → prompt → fix → verify state
- Batch mode with multiple stale habits
- Edge cases from table above
