# Extending org-habit for complex recurrence patterns

**The core gap in Emacs org-mode is not the inability to express complex patterns—diary-sexp entries already handle "second Saturday of month"—but rather the fundamental incompatibility between diary expressions and org-habit's task state machine.** When you mark a diary-sexp scheduled task as DONE, the entire series completes rather than advancing to the next occurrence. This architectural mismatch has persisted since at least 2007 and represents the key challenge for any extension.

Org-habit currently hooks into org-agenda through text properties, building visual consistency graphs from historical state changes stored in LOGBOOK entries. An extension must bridge diary-float's powerful date calculation capabilities with org-habit's state-aware tracking system while maintaining API compatibility with functions like `org-habit-parse-todo` and `org-habit-build-graph`.

## The current org-mode repeater syntax and its fundamental constraints

Org-mode's timestamp repeaters use a simple fixed-interval syntax: `+Nd` (advance N days from scheduled), `++Nd` (advance from scheduled, never into past), and `.+Nd` (advance from completion date). These repeaters are defined by a single interval unit and cannot express calendar-aware patterns.

The repeater format `<2024-01-01 Mon .+1w/2w>` specifies "every week with a 2-week deadline window" but cannot encode "every second Saturday" or "last weekday of month." The underlying issue is architectural: org-mode's timestamp system stores a single date plus an arithmetic offset, while complex recurrence requires either a rule specification (like RFC 5545 RRULE) or calendar function evaluation.

Standard org repeaters are invisible in agenda view—you see only the headline and next scheduled date, not the recurrence pattern itself. This compounds the difficulty of managing complex schedules.

## Existing solutions form a fragmented landscape with significant gaps

**org-recur** (MELPA, 134 stars) extends scheduling with weekday selection (`|Mon,Wed,Fri|`) and day-of-month patterns (`|1,15|`), but its README explicitly states: "org-recur doesn't allow for something like 'first Wednesday of the month'." It uses org-schedule as its backend and inherits its limitations.

**org-habit-plus** (GitHub, unmaintained) introduced a `:HABIT_WEEKDAYS:` property allowing habits restricted to specific weekdays (1-7 mapping), but the project seeks a maintainer and may not work with Org 9+. Its approach of adding custom properties shows one viable extension pattern.

**Diary sexp entries** remain the most powerful option for complex patterns. The `diary-float` function directly expresses nth-weekday patterns:

```elisp
;; Second Saturday of every month
<%%( diary-float t 6 2)>

;; Last Sunday of December (year-end)
<%%(diary-float 12 0 -1)>

;; First weekday of month (requires custom function)
<%%(diary-float-first-weekday t)>
```

However, diary entries behave as calendar events, not repeating tasks. Marking DONE completes the entire series rather than advancing the TODO state—the fundamental incompatibility.

## Org-habit's architecture reveals the integration challenge

Org-habit integrates with org-agenda through a specific pipeline. When agenda builds its list, it calls `org-is-habit-p` to check for `STYLE: habit` property, then `org-habit-parse-todo` extracts a 6-element list structure:

```elisp
;; org-habit-parse-todo returns:
;;   0: Scheduled date (days since epoch)
;;   1: Repeater interval in days
;;   2: Optional deadline date
;;   3: Deadline repeater (if present)
;;   4: List of past completion dates (from LOGBOOK)
;;   5: Repeater type string (".+", "++", "+")
```

This parsed data is attached as the `org-habit-p` text property on agenda lines. During `org-agenda-finalize`, `org-habit-insert-consistency-graphs` iterates through the buffer, calling `org-habit-build-graph` for each habit to generate the visual consistency display.

The key insight: **org-habit's graph depends entirely on (1) a single repeater interval and (2) completion history from state change logs**. The interval determines expected completion frequency; history shows actual completions. Any extension must either produce equivalent data structures or replace the graph-building logic entirely.

The functions requiring compatibility for any extension:

| Function | Purpose | Extension impact |
|----------|---------|------------------|
| `org-habit-parse-todo` | Extract habit data | Must return compatible 6-element list |
| `org-habit-get-faces` | Determine graph colors | Depends on interval vs. actual timing |
| `org-habit-build-graph` | Generate visual graph | Iterates days, needs "was habit due?" logic |
| `org-habit-scheduled-repeat` | Get repeat interval | Called throughout; complex rules need new accessor |

## RFC 5545 RRULE provides the comprehensive model

The iCalendar RRULE specification (RFC 5545) is the industry standard for expressing complex recurrence. Its key components directly address org-mode's limitations:

**BYDAY with ordinal prefix** handles nth-weekday: `BYDAY=2SA` means "second Saturday," `BYDAY=-1SU` means "last Sunday." Multiple values combine: `BYDAY=2SA,4SA` expresses "second and fourth Saturday."

**BYSETPOS** selects specific occurrences from a generated set. "First weekday of month" becomes `FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=1`—generate all weekdays, take the first. "Last weekday" uses `BYSETPOS=-1`.

**BYMONTHDAY with negative values** handles month-end patterns: `-1` means "last day," `-3` means "third from last."

Complex examples relevant to org-habit use cases:

```
# Second and fourth Saturday of month
RRULE:FREQ=MONTHLY;BYDAY=2SA,4SA

# Last Sunday of year
RRULE:FREQ=YEARLY;BYMONTH=12;BYDAY=-1SU

# Every 3rd Thursday (weekly interpretation)
RRULE:FREQ=WEEKLY;INTERVAL=3;BYDAY=TH

# First weekday after the 15th
RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYMONTHDAY=15,16,17,18,19,20,21;BYSETPOS=1
```

RRULE's BYxxx rules operate as either "expand" (generate more occurrences) or "limit" (filter occurrences) depending on FREQ. This interaction matrix determines evaluation order and is the most complex aspect of RRULE implementation.

Taskwarrior's recurrence, by contrast, offers only simple intervals (`daily`, `weekly`, `monthly`, `P3D`) with no calendar-aware patterns—similar to org-mode's current limitations.

## Implementation requires bridging diary-float with org-habit's state machine

The most viable implementation approach combines existing Emacs capabilities:

**For date calculation**, `calendar-nth-named-day` already solves nth-weekday computation:

```elisp
(calendar-nth-named-day 2 6 1 2024)  ; 2nd Saturday of January 2024 → (1 13 2024)
(calendar-nth-named-day -1 0 12 2024) ; Last Sunday of December 2024 → (12 29 2024)
```

This function handles forward counting (1st, 2nd, 3rd) and backward counting (-1 for last, -2 for second-to-last). Combined with `calendar-last-day-of-month` for month-length awareness and leap year handling, the core date mathematics exist.

**For human-readable parsing**, either `peg.el` (GNU ELPA) or `parsec.el` (parser combinators) can tokenize expressions like "second saturday of month":

```elisp
(defconst org-habit-ordinal-alist
  '(("first" . 1) ("second" . 2) ("third" . 3)
	("fourth" . 4) ("fifth" . 5) ("last" . -1)
	("1st" . 1) ("2nd" . 2) ("3rd" . 3) ("4th" . 4)))

(defconst org-habit-weekday-alist
  '(("sunday" . 0) ("monday" . 1) ("tuesday" . 2) ("wednesday" . 3)
	("thursday" . 4) ("friday" . 5) ("saturday" . 6)))
```

**The critical integration challenge** is making complex recurrence work with org-habit's state transitions. Three architectural approaches emerge:

**Approach 1: Custom property with diary-float wrapper**
Store the recurrence rule in a property, override `org-habit-parse-todo` to interpret it, and when marking DONE, calculate and set the next occurrence date explicitly:

```org
* TODO Exercise
SCHEDULED: <2024-01-13 Sat>
:PROPERTIES:
:STYLE: habit
:RECURRENCE: (diary-float t 6 2)  ; 2nd Saturday
:END:
```

The SCHEDULED timestamp holds the *next* occurrence. A custom DONE handler evaluates RECURRENCE to compute the subsequent date and updates SCHEDULED accordingly.

**Approach 2: Virtual repeater with advice**
Advise `org-habit-parse-todo` to detect complex recurrence properties and synthesize a "virtual" repeater interval based on average days between occurrences. The graph would show approximate expected frequency while actual scheduling uses precise calculation.

**Approach 3: Full RRULE property with parallel tracking**
Store RRULE strings directly, implement a parser, and maintain both the RRULE and a computed SCHEDULED. This maximizes compatibility with iCalendar export but requires the most implementation effort.

## Community consensus points toward needed functionality

Mailing list discussions from 2007-2024 consistently identify the same pain points. In 2010, a user asked org-mode creator Carsten Dominik about diary-float TODO entries—no solution was provided. In 2014, users discussed wanting habits on "multiple arbitrary days" but found org's single-SCHEDULED constraint blocking.

The recurring workarounds proposed:
- **org-clone-subtree-with-time-shift** for manual instance creation
- **Separate habits per pattern** (less elegant but works)
- **Custom diary functions** like `diary-habit-last-day-of-month` (requires elisp expertise)

Feature requests remain unaddressed in org-mode core, suggesting this is either technically challenging given org's architecture or lacks a champion implementer.

## Recommended implementation strategy

A practical extension should:

1. **Define a new property** `:RECURRENCE:` accepting either RRULE syntax or a simplified human-readable format that maps to `diary-float` parameters
2. **Advise `org-auto-repeat-maybe`** (called when marking DONE) to check for RECURRENCE property and compute the next occurrence using `calendar-nth-named-day` rather than simple date arithmetic
3. **Patch `org-habit-parse-todo`** to calculate an approximate interval for graph display when RECURRENCE is present, derived from average days between rule-generated occurrences
4. **Provide conversion utilities** between human-readable ("second saturday of month"), diary-float sexp, and RRULE formats

The minimal viable implementation targets the DONE-state transition: instead of `(org-timestamp-change n 'day)` with fixed N, evaluate the recurrence rule to find the next valid date. This preserves org-habit's existing graph logic while enabling complex scheduling.

For graph accuracy with variable-interval patterns (like "2nd and 4th Saturday" which alternates ~14 and ~14-21 days), consider extending `org-habit-build-graph` to accept a date-predicate function rather than a fixed interval, checking "should this habit have been done on date X?" directly against the recurrence rule.

## Technical resources for implementation

Key Emacs source files to study:
- `calendar.el`: `calendar-nth-named-day`, `calendar-last-day-of-month`
- `diary-lib.el`: `diary-float` implementation
- `org-habit.el`: Full module source, particularly `org-habit-parse-todo` and state change handling
- `ox-icalendar.el`: Existing RRULE generation for simple repeaters

Useful packages:
- `ts.el` (alphapapa): Convenient timestamp manipulation
- `parsec.el`: Parser combinators for human-readable input
- `peg.el`: PEG parsing alternative

The gap between org-mode's current capabilities and user needs is well-documented, technically tractable, and awaits an implementation that bridges diary-float's expressive power with org-habit's state-aware consistency tracking.
