# substrate (core layer)
source "~/.config/nushell/modules/substrate/general.nu"
source "~/.config/nushell/modules/substrate/theme.nu"
source "~/.config/nushell/modules/substrate/plugins.nu"
source "~/.config/nushell/modules/substrate/completion.nu"

# workspace — must be before zoxide and aliases
source ~/.config/nushell/dir-info.nu

# session / tools
source "~/.config/nushell/zellij.nu"
source "~/.config/nushell/zoxide.nu"

# forms (interaction layer)
source "~/.config/nushell/modules/forms/keybindings/editors.nu"
source "~/.config/nushell/modules/forms/keybindings/wallpaper.nu"
source "~/.config/nushell/modules/forms/keybindings/ttycmd.nu"

source "~/.config/nushell/modules/forms/scripts/ManifoldOS-Reshaping.nu"
source "~/.config/nushell/modules/forms/scripts/fzf-tools.nu"
source "~/.config/nushell/modules/forms/scripts/ManifoldOS-Reshaping-History.nu"

source "~/.config/nushell/modules/forms/aliases/cli.nu"

# external integrations
source ~/.local/share/nushell/vendor/autoload/atuin.nu
source ($nu.data-dir | path join "carapace-init.nu")

mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")

$env.config.color_config = $light_theme

# starship
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")