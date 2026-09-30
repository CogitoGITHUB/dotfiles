## Proot-Ubuntu on Termux (phone) rules

- No systemd, no Docker. Never suggest `systemctl`, `service`, or docker daemons.
- Phone limits: 7.5GB RAM, battery + mobile data. Prefer cheap models for scout/fix, remote MCPs over heavy locals, never add Chromium/Playwright or local embedding servers.
- Bind loopback only: use `127.0.0.1`, never `0.0.0.0`.
- Paths: proot `$HOME` is `/root/home/shape`; Termux home is `/data/data/com.termux/files/home`. They are NOT the same file. Check `readlink -f` before assuming. `$PATH` includes `/data/data/com.termux/files/usr/bin`.
- Shell is Nushell (`/usr/local/bin/nu`). Emit nu-compatible commands or state bash explicitly.
- TTY-only, small phone screen: keep output terse, `tool_output` is capped at 1000 lines.
- Subnet vault: Emacs config source is `universe/.../Cyberdeck-Emacs/`, loader is `cyberdeck-emacs` (3176 lines). `WIP/` is never read/walked. `~/.config/emacs/*.el` are build artifacts, never edit.
- Before parallel writer agents, assign non-overlapping file ownership. If overlap, serialize or ask.
