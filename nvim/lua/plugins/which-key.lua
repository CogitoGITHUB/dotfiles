-- /014 which-key.lua
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local wk = require('which-key')
    wk.setup({
      preset = "modern",
      delay = 500,
    })
    
    -- Document existing key chains
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>l", group = "LaTeX/LSP" },
      { "<leader>h", group = "Git Hunks" },
      { "<leader>n", group = "Notifications" },
      { "<leader>t", group = "Terminal" },
      { "<leader>s", group = "Split" },
    })
  end,
}
