config.load_autoconfig(False)


# Pure fullscreen, no UI distractions
c.tabs.show = "never"
c.statusbar.show = "never"
c.window.hide_decoration = True

white = "#ffffff"
black = "#000000"

# Force light mode, white background
c.colors.webpage.preferred_color_scheme = "light"
c.colors.webpage.bg = white
c.colors.webpage.darkmode.enabled = False

# UI monochrome

# Status bar
c.colors.statusbar.normal.bg = white
c.colors.statusbar.normal.fg = black
c.colors.statusbar.command.bg = white
c.colors.statusbar.command.fg = black
c.colors.statusbar.insert.bg = white
c.colors.statusbar.insert.fg = black

# Tabs
c.colors.tabs.bar.bg = white
c.colors.tabs.even.bg = white
c.colors.tabs.odd.bg = white
c.colors.tabs.selected.even.bg = white
c.colors.tabs.selected.odd.bg = white

c.colors.tabs.even.fg = black
c.colors.tabs.odd.fg = black
c.colors.tabs.selected.even.fg = black
c.colors.tabs.selected.odd.fg = black

# Completion menu
c.colors.completion.fg = black
c.colors.completion.even.bg = white
c.colors.completion.odd.bg = white
c.colors.completion.match.fg = black

c.colors.completion.category.fg = black
c.colors.completion.category.bg = white

c.colors.completion.item.selected.fg = black
c.colors.completion.item.selected.bg = white

# Prompts (confirm dialogs)
c.colors.prompts.fg = black
c.colors.prompts.bg = white
c.colors.prompts.selected.bg = white

# Hints
c.colors.hints.fg = black
c.colors.hints.bg = white
c.colors.hints.match.fg = black

# Messages (info, error)
c.colors.messages.info.bg = white
c.colors.messages.info.fg = black
c.colors.messages.error.bg = white
c.colors.messages.error.fg = black

# Downloads
c.colors.downloads.bar.bg = white
c.colors.downloads.error.bg = white
c.colors.downloads.error.fg = black
c.colors.downloads.start.bg = white
c.colors.downloads.start.fg = black

# Remove titlebar (Wayland way)
c.window.hide_decoration = True


c.hints.chars = "asdf"
# PURE MINIMAL HINTS
c.hints.border = "0px solid " + white
c.colors.hints.bg = white
c.colors.hints.fg = black
c.colors.hints.match.fg = black
c.hints.radius = 0
