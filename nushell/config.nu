# substrate (core layer)
source "~/.config/nushell/modules/substrate/general.nu"
source "~/.config/nushell/modules/substrate/theme.nu"
source "~/.config/nushell/modules/substrate/plugins.nu"
source "~/.config/nushell/modules/substrate/completion.nu"

# forms (interaction layer)
source "~/.config/nushell/modules/forms/keybindings/editors.nu"
source "~/.config/nushell/modules/forms/keybindings/wallpaper.nu"
source "~/.config/nushell/modules/forms/keybindings/ttycmd.nu"

source "~/.config/nushell/modules/forms/scripts/reshape.nu"
source "~/.config/nushell/modules/forms/scripts/fzf-tools.nu"

source "~/.config/nushell/modules/forms/aliases/cli.nu"

# session / tools
source "~/.config/nushell/zellij.nu"
source "~/.config/nushell/zoxide.nu"

# external integrations
source ~/.local/share/nushell/vendor/autoload/atuin.nu
source ($nu.data-dir | path join "carapace-init.nu")

mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")



