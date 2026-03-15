# /home/asdf/.config/nushell/env.nu

# --- FZF CONFIGURATION (Your single source of truth) ---

# Clear conflicting FZF variables
$env.FZF_DEFAULT_OPTS_FILE = null
$env.FZF_DEFAULT_OPTS = null

# CRITICAL: Force zoxide's internal FZF call to use your global options.
$env._ZO_FZF_OPTS = $env.FZF_DEFAULT_OPTS

# Initialize zoxide (Must be AFTER _ZO_FZF_OPTS is set)
zoxide init nushell | save -f ~/.zoxide.nu

# --- Guix Build Optimizations (Prevent OOM) ---
$env.NIX_BUILD_CORES = 1
$env.GUIX_SUBSTITUTE_URLS = "https://ci.guix.gnu.org https://bordeaux.guix.gnu.org"

