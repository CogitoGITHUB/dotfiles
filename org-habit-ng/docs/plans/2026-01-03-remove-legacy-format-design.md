# Remove Legacy Natural Language Format

## Summary

Remove the legacy natural language recurrence format (e.g., "second saturday of month") from org-habit-ng. Only RRULE format will be supported going forward.

## What Gets Removed

### Legacy parsing (regexps + parser)
- `org-habit-ng--nth-weekday-regexp`
- `org-habit-ng--last-day-regexp`
- `org-habit-ng--first-weekday-regexp`
- `org-habit-ng--parse-recurrence`

### Legacy evaluation (next-occurrence dispatchers)
- `org-habit-ng--next-occurrence` (dispatcher for legacy types)
- `org-habit-ng--next-nth-weekday`
- `org-habit-ng--next-first-weekday`
- `org-habit-ng--next-last-day`

### Fallback paths
- In `--get-recurrence`: remove fallback to `--parse-recurrence`
- In `--after-auto-repeat`: remove legacy `:type` branch
- In `--approximate-interval`: remove `'last-day`, `'first-weekday`, `'nth-weekday` cases

### Tests
All tests using natural language strings like `"second saturday of month"`

### README
Remove "Legacy Natural Language Format" section

## What Gets Kept

### Date helper functions (used by RRULE engine)
- `org-habit-ng--nth-weekday-in-month` — used by RRULE `BYDAY=2SA`
- `org-habit-ng--first-weekday-in-month` — used by RRULE `BYSETPOS=1`
- `org-habit-ng--last-day-of-month` — used by RRULE `BYMONTHDAY=-1`

## Error Handling

When `--get-recurrence` can't parse an RRULE:
- Print a message: `"org-habit-ng: Failed to parse RECURRENCE for '%s'" heading-title`
- Return `nil`
- Caller skips processing that habit (no crash, no silent failure)

## Removal Order

1. Remove legacy regexps and `--parse-recurrence`
2. Remove legacy next-occurrence functions (`--next-nth-weekday`, etc.)
3. Remove `--next-occurrence` dispatcher
4. Update `--get-recurrence` to remove fallback, add warning message
5. Update `--after-auto-repeat` to remove legacy `:type` branch
6. Update `--approximate-interval` to remove legacy cases
7. Remove legacy tests
8. Remove README legacy section

## Verification

Run tests — some will be removed, remaining should pass.
