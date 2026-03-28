source "~/.config/nushell/core-modules/general.nu"
source "~/.config/nushell/core-modules/theme.nu"
source "~/.config/nushell/core-modules/plugins.nu"
source "~/.config/nushell/aeon-modules/keybindings/editors.nu"
source "~/.config/nushell/aeon-modules/keybindings/wallpaper.nu"
source "~/.config/nushell/aeon-modules/keybindings/ttycmd.nu"
source "~/.config/nushell/aeon-modules/keybindings/nix.nu"
source "~/.config/nushell/zoxide.nu"
source "~/.config/nushell/core-modules/completion.nu"
source ~/.zoxide.nu
source ~/.local/share/nushell/vendor/autoload/atuin.nu


mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")





# # zellij
# def start_zellij [] {
#   if 'ZELLIJ' not-in ($env | columns) {
#     if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
#       zellij attach -c
#     } else {
#       zellij
#     }

#     if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
#       exit
#     }
#   }
# }

# start_zellij


