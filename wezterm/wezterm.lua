local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.colors = {
  foreground = '#000000',
  background = '#FFFFFF',
  cursor_bg = '#000000',
  cursor_fg = '#FFFFFF',
  cursor_border = '#000000',
  selection_fg = '#000000',
  selection_bg = '#DDDDDD',
  ansi = { '#000000', '#000000', '#000000', '#000000', '#000000', '#000000', '#000000', '#000000' },
  brights = { '#000000', '#000000', '#000000', '#000000', '#000000', '#000000', '#000000', '#000000' },
}

config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.window_decorations = "NONE"
config.window_background_opacity = 1.0
config.text_background_opacity = 1.0
config.bold_brightens_ansi_colors = false
config.force_reverse_video_cursor = false

config.font = wezterm.font('JetBrains Mono')
config.font_size = 11
config.line_height = 1.05
config.cell_width = 1.0

config.initial_cols = 120
config.initial_rows = 32
config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }

config.scrollback_lines = 10000
config.cursor_blink_rate = 0

-- ===== Disable all key & mouse bindings =====
config.disable_default_key_bindings = true
config.disable_default_mouse_bindings = true

-- ===== Custom key bindings =====
config.keys = {
  -- Paste with Ctrl+Shift+V
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
  -- Copy with Ctrl+Shift+C
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  -- Optional: reload config with Ctrl+Shift+R
  { key = 'R', mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },
}

-- ===== Optional mouse binding: right-click to paste =====
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

return config

