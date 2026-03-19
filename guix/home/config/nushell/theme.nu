# Nushell Theme Configuration - White theme with dark red accents
# Colors: #8B0000 (dark red), #A52A2A (light red), #FFFFFF (white)

# Prompt color
$env.PROMPT_COLOR = "#8B0000"
$env.PROMPT_INDICATOR = "❯"
$env.PROMPT_INDICATOR_VI_INSERT = "❮ "
$env.PROMPT_INDICATOR_VI_NORMAL = "❯ "
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Right prompt colors
$env.RIGHT_PROMPT_COLOR = "#A52A2A"

# Source prompt.nu for full prompt configuration
source ~/.config/nushell/core-modules/general.nu
