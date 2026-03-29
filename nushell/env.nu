# /home/aoeu/.config/nushell/env.nu

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

$env.FZF_DEFAULT_OPTS = "--color=bg:#FFFFFF,bg+:#E8E8E8,fg:#8B0000,fg+:#8B0000,hl:#CC0000,hl+:#FF0000,header:#8B0000,spinner:#8B0000,info:#999999,pointer:#8B0000,marker:#8B0000,prompt:#8B0000,border:#CCCCCC,separator:#CCCCCC,scrollbar:#CCCCCC --border=rounded --padding=1 --margin=1 --info=inline --bind=ctrl-a:select-all --bind=ctrl-j:down --bind=ctrl-k:up"
source ~/.config/nushell/zoxide.nu