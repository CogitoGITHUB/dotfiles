local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ===== Terminal colors & minimal ANSI palette =====
local colors = {
  foreground = '#000000',  -- Black text
  background = '#ffffff',  -- White background
  cursor_bg = '#000000',
  cursor_fg = '#ffffff',
  selection_fg = '#000000',
  selection_bg = '#cccccc',
  -- Minimal ANSI palette
  ansi = {
    "#000000", "#000000", "#000000", "#000000",
    "#000000", "#000000", "#000000", "#000000"
  },
  brights = {
    "#000000", "#000000", "#000000", "#000000",
    "#000000", "#000000", "#000000", "#000000"
  }
}
config.colors = colors

-- ===== Font and basic terminal settings =====
config.font = wezterm.font('JetBrains Mono')
config.font_size = 12
config.scrollback_lines = 20000
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.window_decorations = "NONE"

-- ===== Modal plugin =====
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)
modal.set_default_keys(config)

-- ===== Window frame / tab-bar background =====
config.window_frame = {
  active_titlebar_bg = '#ffffff',
  inactive_titlebar_bg = '#ffffff',
  border_left_width = 0,
  border_right_width = 0,
  border_bottom_height = 0,
}

-- ===== Tabline configuration =====
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    tabs_enabled = true,
    theme = {
      foreground = '#000000',
      background = '#ffffff',
      cursor_bg = '#000000',
      cursor_fg = '#ffffff',
      ansi = {
        "#000000", "#000000", "#000000", "#000000",
        "#000000", "#000000", "#000000", "#000000"
      },
      brights = {
        "#000000", "#000000", "#000000", "#000000",
        "#000000", "#000000", "#000000", "#000000"
      }
    },
    theme_overrides = {
      normal_mode = {
        a = { fg = '#000000', bg = '#ffffff' },
        b = { fg = '#000000', bg = '#ffffff' },
        c = { fg = '#000000', bg = '#ffffff' },
      },
      copy_mode = {
        a = { fg = '#000000', bg = '#ffffff' },
        b = { fg = '#000000', bg = '#ffffff' },
        c = { fg = '#000000', bg = '#ffffff' },
      },
      search_mode = {
        a = { fg = '#000000', bg = '#ffffff' },
        b = { fg = '#000000', bg = '#ffffff' },
        c = { fg = '#000000', bg = '#ffffff' },
      },
      tab = {
        active = { fg = '#000000', bg = '#ffffff' },
        inactive = { fg = '#000000', bg = '#ffffff' },
        inactive_hover = { fg = '#000000', bg = '#eeeeee' },
      },
    },
    section_separators = '',
    component_separators = '',
    tab_separators = '',
  },
  sections = {
    tabline_a = { 'mode' },
    tabline_b = { 'workspace' },
    tabline_c = { ' ' },
    tab_active = { 'index', { 'cwd', padding = { left = 0, right = 1 } } },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    tabline_x = { 'ram', 'cpu' },
    tabline_y = { 'datetime', 'battery' },
    tabline_z = { 'domain' },
  },
})

-- Apply recommended options to WezTerm config
tabline.apply_to_config(config)

-- Force these settings after tabline
config.use_fancy_tab_bar = false
config.window_decorations = "NONE"

return config