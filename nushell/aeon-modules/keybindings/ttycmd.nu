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
      name: hyprland
      modifier: control
      keycode: char_h
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "hyprland"
      }
    },

    # Fastfetch system info
    {
      name: fastfetch
      modifier: control
      keycode: char_f
      mode: emacs
      event: {
        send: executehostcommand
        cmd: "fastfetch"
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
