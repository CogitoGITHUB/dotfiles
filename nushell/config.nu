source "~/.config/nushell/core-modules/general.nu"
source "~/.config/nushell/core-modules/theme.nu"
source "~/.config/nushell/core-modules/plugins.nu"
source "~/.config/nushell/aeon-modules/keybindings/editors.nu"
source "~/.config/nushell/aeon-modules/keybindings/wallpaper.nu"
source "~/.config/nushell/aeon-modules/keybindings/ttycmd.nu"
source "~/.config/nushell/aeon-modules/scripts/reshape.nu"

alias reshape = ^/home/aoeu/.guix-profile/bin/nu -c 'source ~/.config/nushell/aeon-modules/scripts/reshape.nu; reshape'

source "~/.config/nushell/core-modules/completion.nu"
source ~/.zoxide.nu
source ~/.local/share/nushell/vendor/autoload/atuin.nu
source ($nu.data-dir | path join "carapace-init.nu")

mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")


# zellij
def start_zellij [] {
  if 'ZELLIJ' not-in ($env | columns) {
    let sessions = (
      do { zellij list-sessions } | complete | get stdout
      | ansi strip
      | lines
      | where { |l| $l != "" and ($l | str contains "EXITED") == false }
      | each { |l| $l | split row " " | first | str trim }
    )

    if ($sessions | length) == 0 {
      zellij
    } else {
      let choice = (
        $sessions | append "[ new session ]"
        | str join "\n"
        | fzf --prompt="zellij > "
      )

      if $choice == "[ new session ]" {
        zellij
      } else if $choice != "" {
        zellij attach ($choice | str trim)
      }
    }

    if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
      exit
    }
  }
}

start_zellij