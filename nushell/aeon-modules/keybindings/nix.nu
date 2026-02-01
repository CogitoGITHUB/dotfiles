let keybindings = [
 {
  name: "nix flake switch"
  modifier: control
  keycode: char_j
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "bash ~/.config/nushell/aeon-modules/scripts/nix/switch.sh"
   }
 }
 {
  name: "nix test in vm"
  modifier: control
  keycode: char_b
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "bash ~/.config/nushell/aeon-modules/scripts/nix/vm.sh"
   }
 }
 {
  name: "nix test config"
  modifier: control
  keycode: char_k
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "bash ~/.config/nushell/aeon-modules/scripts/nix/test.sh"
   }
 }
 {
  name: "build iso"
  modifier: control
  keycode: char_a
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "bash ~/.config/nushell/aeon-modules/scripts/nix/iso.sh"
   }
 }
 {
  name: "home-manager switch with fzf"
  modifier: control
  keycode: char_x
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "bash ~/.config/nushell/aeon-modules/scripts/nix/home.sh"
   }
 }
];
$env.config.keybindings ++= $keybindings
