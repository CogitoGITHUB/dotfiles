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
    keycode: char_u
    mode: emacs
    event: {
      send: executehostcommand
      cmd: "let sel = (try { zoxide query --list | to text | fzf } catch { '' }); if ($sel | str trim) != '' { cd ($sel | str trim) }"
    }
  }
];

$env.config.keybindings ++= $keybindings