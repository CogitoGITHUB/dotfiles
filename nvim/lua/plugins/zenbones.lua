return {
  "mcchrish/zenbones.nvim",
  dependencies = "rktjmp/lush.nvim",
  priority = 1000,
  config = function()
    vim.o.background = "light"
    vim.cmd("colorscheme zenbones")

    -- base text
    vim.api.nvim_set_hl(0, "Normal",      { fg = "#000000", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#000000", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "StatusLine",  { fg = "#000000", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "LineNr",      { fg = "#999999", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "CursorLineNr",{ fg = "#000000", bold = true })

    -- line highlight (slightly darker gray than background)
    vim.api.nvim_set_hl(0, "CursorLine",  { bg = "#eeeeee" })  -- makes current line visible

    -- visual selection (slightly darker gray)
    vim.api.nvim_set_hl(0, "Visual",      { bg = "#cccccc", fg = "#000000" })

    -- comments in medium gray
    vim.api.nvim_set_hl(0, "Comment",     { fg = "#777777", italic = true })

    -- subtle gray for keywords, types, numbers, strings
    local gray_groups = {
      "Keyword", "Type", "Statement", "Constant",
      "Number", "Boolean", "String", "Identifier",
      "Function", "Operator", "Delimiter", "PreProc",
      "Special", "Structure", "Conditional", "Repeat"
    }
    for _, g in ipairs(gray_groups) do
      vim.api.nvim_set_hl(0, g, { fg = "#444444" })
    end

    -- ensure termguicolors is on for proper grays
    vim.o.termguicolors = true
  end
}

