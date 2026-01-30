let keybindings = [
 { 
  name: "nix flake switch"
  modifier: control
  keycode: char_j
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before switch' --no-gpg-sign }; sudo nixos-rebuild switch --flake .#shapeless --show-trace; try { git push }"
   }
 }
 { 
  name: "nix test in vm"
  modifier: control
  keycode: char_b
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before VM build' --no-gpg-sign }; nixos-rebuild build-vm --flake .#shapeless --show-trace; ./result/bin/run-shapeless-vm"
   }
 }
 { 
  name: "nix test config"
  modifier: control
  keycode: char_k
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before test' --no-gpg-sign }; sudo nixos-rebuild test --flake .#shapeless --show-trace"
   }
 }
 { 
  name: "build iso"
  modifier: control
  keycode: char_i
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before ISO build' --no-gpg-sign }; nix build .#nixosConfigurations.shapeless.config.system.build.isoImage --show-trace --out-link ./iso/result; ls -lh iso/result/iso/*.iso"
   }
 }
 { 
  name: "home-manager switch with fzf"
  modifier: control
  keycode: char_x
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; let user = (ls user-space/home/users/*.nix | get name | path basename | str replace '.nix' '' | str join (char newline) | fzf --prompt='Select user: ' --height=40% --border); if ($user | is-not-empty) { git add -A; try { git diff-index --quiet HEAD } catch { git commit -m $'Auto-commit before switching user ($user)' --no-gpg-sign }; print $'Switching home-manager for ($user)...'; sudo nixos-rebuild switch --flake .#shapeless --show-trace; try { git push } }"
   }
 }
];
$env.config.keybindings ++= $keybindings
