return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    -- primary jump (home row, easy reach)
    { "h", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },

    -- treesitter jump
    { "H", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

    -- remote jump (operator mode)
    { "t", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },

    -- treesitter search
    { "T", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },

    -- toggle search
    { "<c-h>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}

