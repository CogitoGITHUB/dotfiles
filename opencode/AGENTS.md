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
- Read output yourself with `herdr pane read <pane_id>` — never ask the user to paste output.
- Never run into your own pane; use a spare tab/pane. One builder per tree at a time.

## Git: always ship with `git gg`
- After making any changes, always finish with `git gg` (`git add -A && git commit -m 'update' && git push`).
- Applies to both repos: Subnet vault root AND `~/.config` (dotfiles). The `gg` alias exists in both — run it from each root you touched.
