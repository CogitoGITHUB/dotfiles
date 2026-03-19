# /home/asdf/.config/nushell/env.nu

# --- THEME CONFIGURATION (White/Dark Red) ---
# Colors: #8B0000 (dark red), #A52A2A (light red), #FFFFFF (white)

# --- FZF CONFIGURATION (White theme with dark red accents) ---
$env.FZF_DEFAULT_COMMAND = 'fzf --color=bg+:#FFFFFF,bg:#FFFFFF,spinner:#8B0000,hl:#8B0000,fg:#8B0000,header:#8B0000,info:#A52A2A,pointer:#8B0000,marker:#8B0000,fg+:#8B0000,prompt:#8B0000,hl+:#8B0000'
$env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
$env.FZF_ALT_C_COMMAND = $env.FZF_DEFAULT_COMMAND
$env.FZF_DEFAULT_OPTS = '--color=bg+:#FFFFFF,bg:#FFFFFF,spinner:#8B0000,hl:#8B0000,fg:#8B0000,header:#8B0000,info:#A52A2A,pointer:#8B0000,marker:#8B0000,fg+:#8B0000,prompt:#8B0000,hl+:#8B0000 --highlight-line=#FFFFFF --layout=reverse --border=rounded'

# CRITICAL: Force zoxide's internal FZF call to use your global options.
$env._ZO_FZF_OPTS = $env.FZF_DEFAULT_OPTS

# Initialize zoxide (Must be AFTER _ZO_FZF_OPTS is set)
zoxide init nushell | save -f ~/.zoxide.nu

# --- Carapace Configuration ---
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

# --- Guix Build Optimizations (Prevent OOM) ---
$env.NIX_BUILD_CORES = 1
$env.GUIX_SUBSTITUTE_URLS = "https://ci.guix.gnu.org https://bordeaux.guix.gnu.org"

$env.GUIX_PROFILE = "/home/aoeu/.config/guix/current"

let path_without_setuid = ($env.PATH | where {|x| $x != "/run/setuid-programs" })
$env.PATH = [
    "/run/setuid-programs"
    $"($env.GUIX_PROFILE)/bin"
    $"($env.GUIX_PROFILE)/sbin"
    ...$path_without_setuid
]
