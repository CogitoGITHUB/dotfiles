let keybindings = [
 {
  name: "nix flake switch"
  modifier: control
  keycode: char_j
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; notify-send 'NixOS' 'Starting rebuild...' --urgency=low; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before switch' --no-gpg-sign }; try { sudo nixos-rebuild switch --flake .#shapeless --show-trace; notify-send 'NixOS' '✅ Rebuild successful!' --urgency=normal; try { git push } } catch { notify-send 'NixOS' '❌ Rebuild failed!' --urgency=critical }"
   }
 }
 {
  name: "nix test in vm"
  modifier: control
  keycode: char_b
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; notify-send 'NixOS VM' 'Building VM...' --urgency=low; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before VM build' --no-gpg-sign }; try { nixos-rebuild build-vm --flake .#shapeless --show-trace; notify-send 'NixOS VM' '✅ VM built! Starting...' --urgency=normal; ./result/bin/run-ShapelessOS-vm } catch { notify-send 'NixOS VM' '❌ VM build failed!' --urgency=critical }"
   }
 }
 {
  name: "nix test config"
  modifier: control
  keycode: char_k
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; notify-send 'NixOS' 'Testing config...' --urgency=low; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before test' --no-gpg-sign }; try { sudo nixos-rebuild test --flake .#shapeless --show-trace; notify-send 'NixOS' '✅ Test passed!' --urgency=normal } catch { notify-send 'NixOS' '❌ Test failed!' --urgency=critical }"
   }
 }
{
  name: "build iso"
  modifier: control
  keycode: char_a
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; notify-send 'ISO' 'Building ISO...' --urgency=low; try { git pull --rebase --autostash }; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m 'Auto-commit before ISO build' --no-gpg-sign }; try { nix build path:.#nixosConfigurations.shapeless.config.system.build.isoImage --out-link ./iso/result; notify-send 'ISO' '✅ ISO built!' --urgency=normal; ls iso/result/iso/ } catch { notify-send 'ISO' '❌ ISO build failed!' --urgency=critical }"
   }
 }
 {
  name: "home-manager switch with fzf"
  modifier: control
  keycode: char_x
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/ShapelessOS; try { git pull --rebase --autostash }; let user = (ls user-space/home/users/*.nix | get name | path basename | str replace '.nix' '' | str join (char newline) | fzf --prompt='Select user: ' --height=40% --border); if ($user | is-not-empty) { notify-send 'Home-Manager' $'Switching ($user)...' --urgency=low; git add -A; try { git diff-index --quiet HEAD } catch { git commit -m $'Auto-commit before switching user ($user)' --no-gpg-sign }; try { sudo nixos-rebuild switch --flake .#shapeless --show-trace; notify-send 'Home-Manager' $'✅ ($user) switched!' --urgency=normal; try { git push } } catch { notify-send 'Home-Manager' $'❌ ($user) failed!' --urgency=critical } }"
   }
 }
];
$env.config.keybindings ++= $keybindings
