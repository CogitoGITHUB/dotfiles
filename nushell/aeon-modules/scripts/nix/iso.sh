#!/usr/bin/env bash
echo "=== NixOS ISO ==="
cd ~/.config/ShapelessOS
notify-send 'ISO' '💿 Building ISO...' --urgency=low
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign
if nix build path:.#packages.x86_64-linux.isoImage --out-link ./iso/result; then
  notify-send 'ISO' '✅ ISO built!' --urgency=normal
  ls iso/result/iso/
else
  notify-send 'ISO' '❌ ISO build failed!' --urgency=critical
fi
