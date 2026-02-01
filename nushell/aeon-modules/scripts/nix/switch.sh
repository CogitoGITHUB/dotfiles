#!/usr/bin/env bash
cd ~/.config/ShapelessOS
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign 2>/dev/null
notify-send "NixOS" "🔄 Starting rebuild..." --urgency=low
nohup sudo nixos-rebuild switch --flake .#shapeless > /tmp/nixos-switch.log 2>&1 && notify-send "NixOS" "✅ Rebuild successful!" --urgency=normal && git push 2>/dev/null || notify-send "NixOS" "❌ Rebuild failed!" --urgency=critical &
disown
