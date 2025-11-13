let keybindings = [
   
    {
      name: clear
      modifier: control
      keycode: char_v
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "clear"
      }
    },

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
      keycode: char_t
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "zellij"
      }
    },

    # Launch Hyprland from TTY
    {
      name: niri
      modifier: control
      keycode: char_n
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "niri"
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
