local wezterm = require 'wezterm'

local config = {}

-- ===== Visual =====
config.colors = {
  foreground = '#000000',
  background = '#FFFFFF',
  cursor_bg = '#000000',
  cursor_fg = '#FFFFFF',
  selection_fg = '#000000',
  selection_bg = '#DDDDDD',
}

config.font = wezterm.font('JetBrains Mono')
config.font_size = 11

config.enable_tab_bar = false
config.window_decorations = "NONE"
config.scrollback_lines = 20000

return config
