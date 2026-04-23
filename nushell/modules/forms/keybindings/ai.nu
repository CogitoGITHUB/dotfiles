let keybindings = [
 { 
  name: opencode
  modifier: control
  keycode: char_o
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "opencode"
   }
 }
];

$env.config.keybindings ++= $keybindings
