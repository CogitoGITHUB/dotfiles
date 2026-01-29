-- /012 mini.lua
return {
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects (da", dip, etc)
    require('mini.ai').setup()
    
    -- Auto-pairs
    require('mini.pairs').setup()
    
    -- Surround (ysw", ds", cs"')
    require('mini.surround').setup({
      mappings = {
        add = 'sa',            -- Add surrounding
        delete = 'sd',         -- Delete surrounding
        find = 'sf',           -- Find surrounding
        find_left = 'sF',      -- Find surrounding (to the left)
        highlight = 'sh',      -- Highlight surrounding
        replace = 'sr',        -- Replace surrounding
        update_n_lines = 'sn', -- Update n_lines
      },
    })
    
    -- Comments (gcc, gc in visual)
    require('mini.comment').setup()
    
    -- Better text alignment (ga, gA)
    require('mini.align').setup()
    
    -- Animate cursor movements
    require('mini.animate').setup({
      scroll = { enable = false }, -- Snacks already does this
      cursor = {
        enable = true,
        timing = function(n) return 150 / n end,
      },
    })
    
    -- Show color codes (#ff0000, rgb(255,0,0))
    require('mini.hipatterns').setup({
      highlighters = {
        hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
      },
    })
  end,
}
