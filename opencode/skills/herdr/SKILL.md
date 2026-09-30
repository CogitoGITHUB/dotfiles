---
name: herdr
description: Use when running any command that takes over a minute (builds, boots, tests) or when the user should watch live output. Run it in a herdr pane via the herdr CLI instead of a hidden background shell, then read the pane for output — never ask the user to paste output.
---

# Herdr — visible runs

Herdr server is normally running (`herdr status`). Panes outlive this session; the user watches them live.

## Find a target

```bash
herdr tab list
herdr pane list
```

## Run visible

```bash
herdr pane run <pane_id> <command...>
```

- Long builds/tests/boots go here, not hidden background shells.
- Never `run` into the pane this agent lives in — use a spare tab/pane or `herdr tab create` first.
- One builder at a time per tree: concurrent straight/npm builds race on the same dirs.

## Read output yourself

```bash
herdr pane read <pane_id>
```

- Poll the pane, don't ask the user for output.
- Keep reads thin: `head`/`tail` the result, report only status lines and errors.
