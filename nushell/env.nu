# /home/aoeu/.config/nushell/env.nu
carapace _carapace nushell | save -f ($nu.data-dir | path join "carapace-init.nu")
$env.EDITOR = "nvim"

# --- Guix Configuration ---
$env.GUIX_PROFILE = "/home/aoeu/.config/guix/current"
$env.GUIX_SUBSTITUTE_URLS = "https://ci.guix.gnu.org https://bordeaux.guix.gnu.org"


# --- Guile Module Path for LiterativeOS ---
$env.GUILE_LOAD_PATH = $"/home/aoeu/.config/guix/Operating-System:($env.GUILE_LOAD_PATH? | default "")"

# --- PATH Setup ---
let path_without_setuid = ($env.PATH | where {|x| $x != "/run/setuid-programs" })
$env.PATH = [
    "/run/setuid-programs"
    $"($env.GUIX_PROFILE)/bin"
    $"($env.GUIX_PROFILE)/sbin"
    "/home/aoeu/.guix-profile/bin"
    ...$path_without_setuid
]

source ~/.config/nushell/zoxide.nu

$env.FZF_DEFAULT_OPTS = "--color=fg:#8B0000,fg+:#8B0000,hl:#CC0000,hl+:#FF0000,header:#8B0000,spinner:#8B0000,info:#999999,pointer:#8B0000,marker:#8B0000,prompt:#8B0000,border:#8B0000,separator:#8B0000,scrollbar:#8B0000 --border=rounded --padding=1 --margin=1 --info=inline --bind=ctrl-a:select-all --bind=ctrl-j:down --bind=ctrl-k:up"

# --- Guix Home Shepherd ---
let shepherd_socket = $"/run/user/1000/shepherd/socket"
if not ($shepherd_socket | path exists) {
    bash -c "~/.guix-home/on-first-login"
    bash -c "~/.guix-home/profile/bin/shepherd --silent --logfile=$HOME/.local/state/shepherd/shepherd.log"
}
