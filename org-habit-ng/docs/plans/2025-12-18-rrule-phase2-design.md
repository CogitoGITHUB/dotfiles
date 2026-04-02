# Phase 2: Interactive RRULE Builder - Design Document

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Provide an intuitive UI for constructing RRULE strings without memorizing syntax.

**Architecture:** Progressive wizard flow that asks questions until the rule is fully defined. Transient-based UI with completing-read fallback for accessibility. Preview with natural language description before saving.

**Tech Stack:** Transient.el, completing-read, org-habit-plus RRULE engine (Phase 1)

---

## Entry Point

Single command: `org-habit-plus-set-recurrence`

- Works on any org heading (creates `:RECURRENCE:` property)
- Detects existing recurrence and offers modify/clear
- Auto-detects GUI vs terminal for UI choice

## Wizard Flow

The wizard progressively builds the RRULE through a series of questions. Each step narrows down the rule until it's fully defined.

### Step 1: Frequency

```
How often does this repeat?

  [d] Daily
  [w] Weekly
  [m] Monthly
  [y] Yearly
  [c] Custom RRULE...
```

If Custom: prompt for raw RRULE string, validate, skip to Preview.

### Step 2: Interval

```
Every how many [days/weeks/months/years]? (default: 1)
```

Minibuffer prompt with default of 1.

### Step 3: Day Constraints

Varies based on frequency selected in Step 1.

**If Daily:** Skip this step (no day constraints needed).

**If Weekly:**
```
Which days?  [M] [T] [W] [R] [F] [S] [U]
             Mon Tue Wed Thu Fri Sat Sun

Press letter to toggle, RET when done
```

Uses academic weekday abbreviations (R=Thursday, U=Sunday).
If no days selected, defaults to current day of week.

**If Monthly:**
```
Repeat on:

  [d] Specific day of month (e.g., the 15th)
  [n] Nth weekday (e.g., 2nd Saturday)
  [l] Last specific weekday (e.g., last Friday)
  [e] Last day of month
```

Then based on selection:
- If [d]: "Which day of month? (1-31): "
- If [n]: "Which day?" → Mon/Tue/.../Sun, then "Which occurrence?" → First/Second/Third/Fourth/Fifth
- If [l]: "Which day?" → Mon/Tue/.../Sun
- If [e]: No further prompts

**If Yearly:**
```
Which month?
```

Completing-read with month names (January...December).

Then same day options as Monthly:
```
Repeat on:

  [d] Specific day of month (e.g., the 15th)
  [n] Nth weekday (e.g., 2nd Saturday)
  [l] Last specific weekday (e.g., last Friday)
  [e] Last day of month
```

### Step 4: Flexibility Window

```
Add flexibility window?

  A flexibility window lets you complete the habit within N days
  of the scheduled date. Useful for habits that don't need exact
  timing, like "water plants every 3 days, give or take a day."

[y] Yes, add window  [n] No, exact dates only
```

If yes: "Complete within how many days of scheduled date? "

Generates `X-FLEXIBILITY=N` extension.

### Step 5: Repeat From

```
When you mark DONE, advance next occurrence from:

  [s] Scheduled date
      If scheduled for Mon and you complete on Wed,
      next occurrence is calculated from Mon.

  [c] Completion date
      If scheduled for Mon and you complete on Wed,
      next occurrence is calculated from Wed.
```

Generates `X-REPEAT-FROM=scheduled` or `X-REPEAT-FROM=completion`.

### Step 6: Preview & Confirm

```
Recurrence Preview
──────────────────

  Every 2 weeks on Monday, Wednesday, Friday

  RRULE: FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;X-REPEAT-FROM=scheduled

  Next 3 occurrences:
    • Mon Jan 13, 2025
    • Wed Jan 15, 2025
    • Fri Jan 17, 2025

[y] Save  [n] Cancel  [e] Start over
```

Natural language comes from `org-habit-plus-rrule-to-human` (Phase 1).
Next occurrences from `org-habit-plus-next-scheduled` called iteratively.

## Editing Existing Recurrence

When called on heading with `:RECURRENCE:` property:

```
Current recurrence:

  Every second Saturday of the month
  RRULE: FREQ=MONTHLY;BYDAY=2SA

[m] Modify  [c] Clear  [q] Cancel
```

- **Modify**: Enters wizard flow from Step 1 (values not pre-populated in v1)
- **Clear**: Removes `:RECURRENCE:` property after confirmation

## Completing-Read Fallback

For terminal users or when `org-habit-plus-use-completing-read` is non-nil:

1. **Frequency**: completing-read with "Daily", "Weekly", "Monthly", "Yearly", "Custom"
2. **Interval**: read-number
3. **Day constraints**: completing-read-multiple for weekdays, completing-read for monthly options
4. **Flexibility**: y-or-n-p, then read-number if yes
5. **Repeat from**: completing-read with "Scheduled date", "Completion date"
6. **Preview**: displayed in echo area with y-or-n-p confirmation

Auto-detected via `(display-graphic-p)` with customizable override.

## Customization Variables

```elisp
(defcustom org-habit-plus-use-completing-read nil
  "When non-nil, use completing-read instead of transient menus.
When nil, auto-detect based on display capabilities."
  :type 'boolean
  :group 'org-habit-plus)

(defcustom org-habit-plus-default-repeat-from 'scheduled
  "Default value for X-REPEAT-FROM when not specified.
Options are `scheduled' or `completion'."
  :type '(choice (const :tag "Scheduled date" scheduled)
                 (const :tag "Completion date" completion))
  :group 'org-habit-plus)

(defcustom org-habit-plus-preview-occurrences 3
  "Number of future occurrences to show in preview."
  :type 'integer
  :group 'org-habit-plus)
```

## Function Overview

| Function | Purpose |
|----------|---------|
| `org-habit-plus-set-recurrence` | Main entry point command |
| `org-habit-plus--template-menu` | Transient menu definition |
| `org-habit-plus--prompt-number` | Minibuffer number input |
| `org-habit-plus--weekday-picker` | Toggle-style day selector |
| `org-habit-plus--nth-weekday-prompt` | Two-step nth weekday flow |
| `org-habit-plus--prompt-repeat-from` | Scheduled vs completion choice |
| `org-habit-plus--show-preview` | Preview buffer with confirmation |
| `org-habit-plus--save-recurrence` | Write property to heading |
| `org-habit-plus--completing-read-flow` | Fallback non-transient flow |

## Dependencies

- **transient.el** (built-in Emacs 28+, MELPA for older)
- **org-habit-plus.el** Phase 1 functions:
  - `org-habit-plus-parse-rrule` - validate syntax
  - `org-habit-plus-rrule-to-human` - natural language
  - `org-habit-plus-next-scheduled` - calculate occurrences
