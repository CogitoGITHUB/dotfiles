let keybindings = [
 { 
  name: say_script
  modifier: control
  keycode: char_v
  mode: emacs
  event: {
    send: executehostcommand
    cmd: "nu -c '~/.config/nushell/aeon-modules/scripts/say.nu'"
   }
 }

      # zellij
    {
      name: zellij
      modifier: control
      keycode: char_z
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "zellij"
      }
    },

    # zoxide with fzf
    {
      name: zoxide-fzf
      modifier: control
      keycode: char_u
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "cdf"
      }
    },
   ];

$env.config.keybindings ++= $keybindings
