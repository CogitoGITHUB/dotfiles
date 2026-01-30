let keybindings = [
 { 
  name: "nix flake switch"
  modifier: control
  keycode: char_j
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/nixos; git pull --rebase --autostash; git add -A; git diff-index --quiet HEAD || git commit -m 'Auto-commit before switch' --no-verify; sudo nixos-rebuild switch --flake .#shapeless --show-trace; git push || true"
   }
 }
 { 
  name: "nix test in vm"
  modifier: control
  keycode: char_b
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/nixos; git pull --rebase --autostash; git add -A; git diff-index --quiet HEAD || git commit -m 'Auto-commit before VM build' --no-verify; nixos-rebuild build-vm --flake .#shapeless --show-trace; ./result/bin/run-shapeless-vm"
   }
 }
 { 
  name: "nix test config"
  modifier: control
  keycode: char_k
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/nixos; git pull --rebase --autostash; git add -A; git diff-index --quiet HEAD || git commit -m 'Auto-commit before test' --no-verify; sudo nixos-rebuild test --flake .#shapeless --show-trace"
   }
 }
 { 
  name: "home-manager switch with fzf"
  modifier: control
  keycode: char_x
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/nixos; git pull --rebase --autostash; let user = (ls users/*.nix | get name | path basename | str replace '.nix' '' | str join (char newline) | fzf --prompt='Select user: ' --height=40% --border); if ($user | is-not-empty) { git add -A; git diff-index --quiet HEAD || git commit -m $'Auto-commit before switching user ($user)' --no-verify; print $'Switching home-manager for ($user)...'; sudo nixos-rebuild switch --flake .#shapeless --show-trace; git push || true }"
   }
 }
];
$env.config.keybindings ++= $keybindings
