return {
  "goolord/alpha-nvim",
  lazy = false,
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                               __",
      "             ___ ___  ____  / /_  ____ ______",
      "            / _ ` _ \\/ __ \\/ __ \\/ __ `/ ___/",
      "           / / / / / / /_/ / / / / /_/ / /",
      "          /_/ /_/ /_/ .___/_/ /_/\\__,_/_/",
      "                   /_/                   ",
    }
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
      dashboard.button("n", "  New File", ":ene <CR>"),
      dashboard.button("r", "  Recent Files", ":Telescope oldfiles <CR>"),
      dashboard.button("t", "  Toggle Term", ":ToggleTerm <CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    alpha.setup(dashboard.config)
  end,
}