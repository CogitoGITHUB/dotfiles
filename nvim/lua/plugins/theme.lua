return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.cmd("hi Normal guifg=#000000 guibg=#ffffff")
      vim.cmd("hi Comment guifg=#444444 gui=italic")
      vim.cmd("hi Keyword guifg=#000000 gui=bold")
    end,
  },
}

