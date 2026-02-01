#!/usr/bin/env bash
echo "=== NixOS Home-Manager ==="
cd ~/.config/ShapelessOS
user=$(ls user-space/home/users/*.nix | xargs -I{} basename {} .nix | fzf --prompt='Select user: ' --height=40% --border)
if [ -n "$user" ]; then
  echo "Switching home-manager for: $user"
  notify-send 'Home-Manager' "🏠 Switching $user..." --urgency=low
  git pull --rebase --autostash 2>/dev/null
  git add -A
  git diff-index --quiet HEAD || git commit -m "Auto-commit before $user" --no-gpg-sign
  if sudo nixos-rebuild switch --flake .#shapeless; then
    notify-send 'Home-Manager' "✅ $user switched!" --urgency=normal
    git push 2>/dev/null
  else
    notify-send 'Home-Manager' "❌ $user failed!" --urgency=critical
  fi
fi
