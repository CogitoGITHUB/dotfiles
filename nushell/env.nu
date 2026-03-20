# /home/asdf/.config/nushell/env.nu

# --- Guix Configuration ---
# Custom Guix is at: /home/aoeu/.config/guix/current -> /var/guix/profiles/per-user/aoeu/current-guix
# This is the LiterativeOS declarative system config manager - all packages/services are declared in guix/config.scm
# PATH puts custom guix FIRST to override system guix at /run/current-system/profile/bin/guix
$env.GUIX_PROFILE = "/home/aoeu/.config/guix/current"
$env.GUIX_SUBSTITUTE_URLS = "https://ci.guix.gnu.org https://bordeaux.guix.gnu.org"
$env.NIX_BUILD_CORES = 1  # Prevent OOM during builds

# --- PATH Setup ---
# Order matters: setuid-programs -> custom guix -> everything else
let path_without_setuid = ($env.PATH | where {|x| $x != "/run/setuid-programs" })
$env.PATH = [
    "/run/setuid-programs"
    $"($env.GUIX_PROFILE)/bin"
    $"($env.GUIX_PROFILE)/sbin"
    ...$path_without_setuid
]

# Initialize zoxide (Must be AFTER _ZO_FZF_OPTS is set)
zoxide init nushell | save -f ~/.zoxide.nu


$env.FZF_DEFAULT_OPTS = '--color=bg:#FFFFFF,bg+:#E8E8E8,fg:#8B0000,fg+:#8B0000,hl:#CC0000,hl+:#FF0000,header:#8B0000,spinner:#8B0000,info:#999999,pointer:#8B0000,marker:#8B0000,prompt:#8B0000,border:#CCCCCC,separator:#CCCCCC,scrollbar:#CCCCCC --border=rounded --padding=1 --margin=1 --info=inline --bind=ctrl-a:select-all --bind=ctrl-j:down --bind=ctrl-k:up'