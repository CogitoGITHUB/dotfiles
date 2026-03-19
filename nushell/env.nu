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

# --- FZF Configuration ---
# Clear conflicting FZF variables
$env.FZF_DEFAULT_OPTS_FILE = null
$env.FZF_DEFAULT_OPTS = null
# Force zoxide's internal FZF call to use your global options.
$env._ZO_FZF_OPTS = $env.FZF_DEFAULT_OPTS

# Initialize zoxide (Must be AFTER _ZO_FZF_OPTS is set)
zoxide init nushell | save -f ~/.zoxide.nu