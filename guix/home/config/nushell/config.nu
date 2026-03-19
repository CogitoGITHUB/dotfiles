# Git config
$env.GIT_AUTHOR_NAME = "CogitoGITHUB"
$env.GIT_AUTHOR_EMAIL = "vlasceanupaulinoionut@gmail.com"
$env.GIT_COMMITTER_NAME = "CogitoGITHUB"
$env.GIT_COMMITTER_EMAIL = "vlasceanupaulinoionut@gmail.com"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Fix sudo PATH - prepend setuid-programs to string PATH before converting
let clean_path = ($env.PATH | split row ':' | where {|x| $x != "/run/setuid-programs"} | str join ":")
$env.PATH = $"/run/setuid-programs:($clean_path)"

# Starship prompt initialization
mkdir ~/.config/starship  -p
starship init nu | save -f ~/.config/starship/init.nu
source ~/.config/starship/init.nu

# Atuin initialization
atuin init nu | save -f ~/.local/share/nushell/vendor/autoload/atuin.nu

source "~/.config/nushell/core-modules/general.nu"
source "~/.config/nushell/core-modules/theme.nu"
source "~/.config/nushell/core-modules/plugins.nu"
source "~/.config/nushell/aeon-modules/keybindings/editors.nu"
source "~/.config/nushell/aeon-modules/aliases/basic.nu"
source "~/.config/nushell/aeon-modules/keybindings/wallpaper.nu"
source "~/.config/nushell/aeon-modules/keybindings/ttycmd.nu"
source "~/.config/nushell/aeon-modules/keybindings/nix.nu"
source "~/.config/nushell/zoxide.nu"
source "~/.config/nushell/core-modules/completion.nu"
source ~/.zoxide.nu
source ~/.local/share/nushell/vendor/autoload/atuin.nu

# Carapace completions
carapace _carapace nushell | save -f $"($nu.cache-dir)/carapace.nu"
source $"($nu.cache-dir)/carapace.nu"

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
