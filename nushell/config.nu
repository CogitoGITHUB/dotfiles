# Git config
$env.GIT_AUTHOR_NAME = "CogitoGITHUB"
$env.GIT_AUTHOR_EMAIL = "vlasceanupaulinoionut@gmail.com"
$env.GIT_COMMITTER_NAME = "CogitoGITHUB"
$env.GIT_COMMITTER_EMAIL = "vlasceanupaulinoionut@gmail.com"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Source Guix system profile
$env.PATH = ($env.PATH | split row ':' | prepend "/run/current-system/profile/bin" | prepend "/run/current-system/profile/sbin" | prepend "$HOME/.guix-profile/bin" | prepend "$HOME/.guix-profile/sbin" | str join ":")

source "~/.config/nushell/core-modules/general.nu"
source "~/.config/nushell/core-modules/theme.nu"
source "~/.config/nushell/core-modules/plugins.nu"
source "~/.config/nushell/aeon-modules/keybindings/editors.nu"
source "~/.config/nushell/aeon-modules/aliases/basic.nu"
source "~/.config/nushell/aeon-modules/keybindings/wallpaper.nu"
source "~/.config/nushell/aeon-modules/keybindings/ttycmd.nu"
source "~/.config/nushell/aeon-modules/keybindings/nix.nu"
source "~/.config/nushell/zoxide.nu"
source "~/.guix-profile/share/atuin/init.nu"
source "~/.config/nushell/core-modules/completion.nu"
source ~/.zoxide.nu


# zellij
def start_zellij [] {
  if 'ZELLIJ' not-in ($env | columns) {
    if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
      zellij attach -c
    } else {
      zellij
    }

    if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
      exit
    }
  }
}

start_zellij


