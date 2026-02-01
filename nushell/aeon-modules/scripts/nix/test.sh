#!/usr/bin/env bash
echo "=== NixOS Test ==="
cd ~/.config/ShapelessOS
notify-send 'NixOS' '🧪 Testing config...' --urgency=low
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign
if sudo nixos-rebuild test --flake .#shapeless; then
  notify-send 'NixOS' '✅ Test passed!' --urgency=normal
else
  notify-send 'NixOS' '❌ Test failed!' --urgency=critical
fi
