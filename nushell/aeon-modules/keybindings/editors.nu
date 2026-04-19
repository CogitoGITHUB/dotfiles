let keybindings = [ 
{
    name: "emacs"
    modifier: "control"
    keycode: "char_e"
    mode: ["emacs"]
    event: {
      send: "executehostcommand"
      cmd: 'emacs -nw --eval "(dired \".\")"'
    }
  },

{
    name: "nvim"
    modifier: "control"
    keycode: "char_n"
    mode: ["emacs"]
    event: {
      send: "executehostcommand"
      cmd: 'nvim'
    }
  },

]

$env.config.keybindings ++= $keybindings

