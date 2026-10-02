# Global instructions — loaded in every session

## Environment: proot-Ubuntu on Termux (phone)
- No systemd, no Docker. Never suggest `systemctl`, `service`, or docker daemons.
- Phone limits: 7.5GB RAM, battery + mobile data. Prefer cheap models for scout/fix, remote MCPs over heavy locals.
- Bind loopback only: `127.0.0.1`, never `0.0.0.0`.
- `$HOME` is `/root/home/shape`; Termux home is `/data/data/com.termux/files/home`. NOT the same files — check `readlink -f` before assuming.
- Login shell is Nushell (`/usr/local/bin/nu`). Emit nu-compatible commands or state bash explicitly.
- TTY-only, small phone screen: keep output terse.

## Todo convention
- "todo this/that" without a stated location means append to `/root/home/shape/Subnet/TODO.org` (top level, never `WIP/`).
- One `* TODO <item>` per line, with date when useful.

## Emacs access
- Neomacs 0.0.19 available via `neomacsclient`. For quick elisp eval use `neomacsclient --eval '(...)'`.
- emacs-mcp-server tools (when its MCP is connected): `eval-elisp`, `get-diagnostics`, `org-agenda`, `org-search`, `org-get-node`, `org-capture`, `org-update-node`, `org-refile`, `org-archive`, `org-clock`.
- Never edit `~/.config/emacs/*.el` — build artifacts.

## Herdr: run visible (skill: herdr)
- Herdr is the terminal multiplexer. Long runs (builds, boots, tests) go in a herdr pane via `herdr pane run <pane_id> <cmd>`, never hidden background shells.
- Read output yourself with `herdr pane read <pane_id>` — never ask the user to paste output. Always read right after sending to confirm it started.
- Never run into your own pane; use a spare tab/pane. One builder per tree at a time.
- REUSE A TAB, do not pile up new ones. `herdr tab list` first; if a spare pane/tab already exists, use it. Only `herdr tab create` when there is genuinely none spare.
- Name every tab you use for work: `herdr tab rename <TAB_ID> <short-task-slug>` (e.g. `aiu-stage-loader`). Do not leave default numeric labels on tabs you are using.

## Long runs: never block on them
- The tab exists so the USER CAN WATCH. Stream output into the pane with `tee`, never `> logfile` — a fully redirected run makes the tab a hidden shell and defeats the point. `sh -c 'cmd 2>&1 | tee /tmp/run.log; echo EXIT=$? >> /tmp/run.log'` gives live output *and* a greppable log.
- NEVER `sleep` in a loop waiting for a build/boot/test to finish, and never sit in a foreground call that outlasts the work. That burns minutes of wall clock and the phone's battery for nothing.
- After sending a long run to a herdr pane, arm a completion watcher with the shell tool's `background: true` and `timeout: 0`, then STOP and end the turn. The harness notifies you on completion — that notification is the "echo".
- The watcher should block on the run's own completion signal (the command's `BOOT-EXIT=` / `EXIT=` marker line, a `done` file, `herdr pane read` showing the prompt back) and then print the summary lines you actually need: exit code, key counts, timings, artifact paths.
- Do the useful non-dependent work while it runs (reading code, drafting the report, editing files it does not touch), then answer. If there is no such work, end the response and wait for the notification.
- Do not re-issue the same wait loop, and do not poll the watcher output file.

## Git: always ship with `git gg`
- After making any changes, always finish with `git gg` (`git add -A && git commit -m 'update' && git push`).
- Applies to both repos: Subnet vault root AND `~/.config` (dotfiles). The `gg` alias exists in both — run it from each root you touched.
