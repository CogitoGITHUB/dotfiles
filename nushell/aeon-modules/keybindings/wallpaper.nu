# Wallpaper picker keybindings
let keybindings = [
    # Launch wallpaper picker
    {
        name: wallpaper_picker
        modifier: control
        keycode: char_w
        mode: emacs
        event: {
            send: "executehostcommand"
            cmd: "~/.config/niri/scripts/wallpaper-picker.nu"
        }
    }
];

# Merge wallpaper keybindings with existing keybindings
$env.config.keybindings ++= $keybindings
