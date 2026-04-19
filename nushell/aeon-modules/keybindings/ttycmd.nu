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
    name: git_gg
    modifier: control
    keycode: char_g
    mode: emacs
    event: {
      send: executehostcommand
      cmd: "git gg"
    }
  }
  {
    name: reshape
    modifier: control
    keycode: char_s
    mode: emacs
    event: {
      send: executehostcommand
      cmd: "reshape"
    }
  }

{
    name: rmpc
    modifier: control
    keycode: char_p
    mode: emacs
    event: {
      send: executehostcommand
      cmd: "rmpc"
    }
  }
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