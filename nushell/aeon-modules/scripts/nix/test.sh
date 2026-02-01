#!/usr/bin/env bash
cd ~/.config/ShapelessOS
git pull --rebase --autostash 2>/dev/null
git add -A
git diff-index --quiet HEAD || git commit -m "Auto-commit $(date +%H:%M:%S)" --no-gpg-sign 2>/dev/null
notify-send "NixOS" "🧪 Testing..." --urgency=low
nohup sudo nixos-rebuild test --flake .#shapeless > /tmp/nixos-test.log 2>&1 && notify-send "NixOS" "✅ Test passed!" --urgency=normal || notify-send "NixOS" "❌ Test failed!" --urgency=critical &
disown
