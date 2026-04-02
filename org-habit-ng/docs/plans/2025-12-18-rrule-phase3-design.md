# Phase 3: RRULE-Aware Consistency Graph - Design Document

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace org-habit's fixed-interval graph with an RRULE-aware version that accurately shows due dates for complex recurrence patterns.

**Architecture:** Advice around `org-habit-build-graph` that intercepts RRULE habits and computes accurate due dates, while delegating standard habits to the original implementation.

**Tech Stack:** org-habit faces/glyphs, org-habit-plus Phase 1 RRULE engine, advice-add

---

## Problem Statement

`org-habit-build-graph` assumes a fixed interval between due dates. For "2nd Saturday of month", the gap varies 28-35 days. The current approximate interval (30 days) causes inaccurate coloring in the consistency graph.

## Architecture

```
org-agenda-finalize
    ↓
org-habit-insert-consistency-graphs
    ↓
org-habit-build-graph  ←── advice intercepts here
    ↓
[RRULE habit?]
    ├─ No  → delegate to original org-habit-build-graph
    └─ Yes → org-habit-plus--build-graph
                ↓
            1. Get RRULE from org entry (via marker)
            2. Generate due dates in window
            3. For each day: find nearest due date, pick face
            4. Mark done-dates with * glyph
            5. Return colored graph string
```

## Core Functions

### `org-habit-plus--get-due-dates-in-range (rule start-day end-day)`

Generate all RRULE due dates within a day range.

- Takes parsed RRULE and day range (days since epoch)
- Iterates forward using `org-habit-plus--rrule-next-occurrence`
- Returns sorted list of due dates (as day numbers) within range
- Stops when next occurrence exceeds end-day

### `org-habit-plus--get-nearest-due-date (day due-dates)`

Find the nearest due date to a given day.

- Returns `(distance . due-date)` where distance is negative if day is before due, positive if after
- Used to determine face for each day in graph

### `org-habit-plus--build-graph (habit starting current ending rrule)`

Build the consistency graph for an RRULE habit.

- Same output format as `org-habit-build-graph`
- Gets flexibility from RRULE's `:flexibility` property
- For each day in range:
  - Compute nearest due date
  - Apply face using org-habit's color logic
  - Mark done-dates with `org-habit-completed-glyph` (*)
  - Mark today with `org-habit-today-glyph` (!)
- Returns propertized string

### `org-habit-plus--get-rrule-from-agenda-marker`

Retrieve RRULE from the source org entry.

- Gets `org-marker` text property from current agenda line
- Uses marker to read `:RECURRENCE:` property from source buffer
- Parses RRULE if present, returns nil otherwise

## Face Color Logic

Matches org-habit's exact progression:

```
distance = day - nearest_due_date
flexibility = X-FLEXIBILITY value (default 0)

if distance < 0:
    → org-habit-clear-face (blue) - before due date

elif distance <= flexibility:
    → org-habit-ready-face (green) - on due date or within flexibility

elif distance == flexibility + 1:
    → org-habit-alert-face (yellow/orange) - at deadline

else:
    → org-habit-overdue-face (red) - overdue
```

Future days (after `current`) use the `-future-face` variants.

If `org-habit-show-done-always-green` is set and day is done, use green.

## Advice Setup

```elisp
(defun org-habit-plus--around-build-graph (orig-fun habit starting current ending)
  "Advice to use RRULE-aware graph for habits with RECURRENCE property."
  (let ((rrule (org-habit-plus--get-rrule-from-agenda-marker)))
    (if rrule
        (condition-case err
            (org-habit-plus--build-graph habit starting current ending rrule)
          (error
           (message "org-habit-plus graph error: %s, using fallback" err)
           (funcall orig-fun habit starting current ending)))
      (funcall orig-fun habit starting current ending))))
```

The `condition-case` ensures bugs in our code don't break the agenda.

## Testing Approach

**Unit tests:**
- `org-habit-plus--get-due-dates-in-range` - weekly, monthly, yearly patterns
- `org-habit-plus--get-nearest-due-date` - edge cases
- Face selection for each color zone

**Integration tests:**
- Graph for "2nd Saturday of month" - correct colors around due dates
- Graph with `X-FLEXIBILITY=2` - extended green zone
- Graph with done-dates - correct `*` glyph placement
- Fallback when RRULE parsing fails

**Manual verification:**
- Visual check in actual agenda buffer
