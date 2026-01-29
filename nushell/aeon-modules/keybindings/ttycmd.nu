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

    {
      name: zoxide_fzf
      modifier: control
      keycode: char_a
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "fa"
      }
    },
        
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

    # Launch scroll from TTY
    {
      name: scroll
      modifier: control
      keycode: char_s
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "scroll"
      }
    },
    # Reboot system
    {
      name: reboot
      modifier: control
      keycode: char_q
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "systemctl reboot"
      }
    }
];

$env.config.keybindings ++= $keybindings
