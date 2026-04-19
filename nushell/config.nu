source "~/.config/nushell/core-modules/general.nu"
source "~/.config/nushell/core-modules/theme.nu"
source "~/.config/nushell/core-modules/plugins.nu"
source "~/.config/nushell/aeon-modules/keybindings/editors.nu"
source "~/.config/nushell/aeon-modules/keybindings/wallpaper.nu"
source "~/.config/nushell/aeon-modules/keybindings/ttycmd.nu"
source "~/.config/nushell/aeon-modules/scripts/reshape.nu"
source "~/.config/nushell/aeon-modules/aliases/guix.nu"
source "~/.config/nushell/aeon-modules/aliases/cli.nu"
source "~/.config/nushell/core-modules/completion.nu"
source "~/.config/nushell/zellij.nu"
source "~/.config/nushell/zoxide.nu"
source ~/.local/share/nushell/vendor/autoload/atuin.nu
source ($nu.data-dir | path join "carapace-init.nu")

mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")




