let keybindings = [ 
{
    name: "emacs"
    modifier: "control"
    keycode: "char_e"
    mode: ["emacs"]
    event: {
      send: "executehostcommand"
      cmd: 'emacs -nw'
    }
  },

]

$env.config.keybindings ++= $keybindings

