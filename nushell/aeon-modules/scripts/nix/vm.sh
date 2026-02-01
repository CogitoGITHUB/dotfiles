#!/usr/bin/env bash
echo "=== NixOS VM ==="
cd ~/.config/ShapelessOS
notify-send 'NixOS VM' '🖥️ Building VM...' --urgency=low
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign
if nixos-rebuild build-vm --flake .#shapeless; then
  notify-send 'NixOS VM' '✅ VM built! Starting...' --urgency=normal
  ./result/bin/run-ShapelessOS-vm
else
  notify-send 'NixOS VM' '❌ VM build failed!' --urgency=critical
fi
