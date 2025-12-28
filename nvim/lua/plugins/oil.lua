return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional: add a keymap to browse with oil
  keys = {
    { "<leader>pv", function() require("oil").toggle_float() end, desc = "Open parent directory" },
  },
}
