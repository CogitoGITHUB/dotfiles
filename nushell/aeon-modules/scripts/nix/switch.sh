#!/usr/bin/env bash
echo "=== NixOS Switch ==="
cd ~/.config/ShapelessOS
notify-send 'NixOS' '🔄 Starting rebuild...' --urgency=low
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign
if sudo nixos-rebuild switch --flake .#shapeless; then
  notify-send 'NixOS' '✅ Rebuild successful!' --urgency=normal
  git push 2>/dev/null
else
  notify-send 'NixOS' '❌ Rebuild failed!' --urgency=critical
fi
