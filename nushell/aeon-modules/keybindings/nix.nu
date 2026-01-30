let keybindings = [
 { 
  name: "nix flake switch"
  modifier: control
  keycode: char_j
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "sudo nixos-rebuild switch --flake .#shapeless"
   }
 }
 { 
  name: "nix test in vm"
  modifier: control
  keycode: char_b
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "nixos-rebuild build-vm --flake .#shapeless; ./result/bin/run-shapeless-vm"
   }
 }
 { 
  name: "nix test config"
  modifier: control
  keycode: char_k
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "sudo nixos-rebuild test --flake .#shapeless"
   }
 }
 { 
  name: "home-manager switch with fzf"
  modifier: control
  keycode: char_x
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "cd ~/.config/nixos; let user = (ls users/*.nix | get name | path basename | str replace '.nix' '' | str join (char newline) | fzf --prompt='Select user: ' --height=40% --border); if ($user | is-not-empty) { print $'Switching home-manager for ($user)...'; sudo nixos-rebuild switch --flake .#shapeless }"
   }
 }
];
$env.config.keybindings ++= $keybindings
