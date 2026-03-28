return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      theme = {
        normal = {
          a = { fg = '#ffffff', bg = '#8B0000', gui = 'bold' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
        insert = {
          a = { fg = '#ffffff', bg = '#8B0000', gui = 'bold' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
        visual = {
          a = { fg = '#ffffff', bg = '#8B0000', gui = 'bold' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
        replace = {
          a = { fg = '#ffffff', bg = '#8B0000', gui = 'bold' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
        command = {
          a = { fg = '#ffffff', bg = '#8B0000', gui = 'bold' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
        inactive = {
          a = { fg = '#8B0000', bg = '#ffffff' },
          b = { fg = '#8B0000', bg = '#ffffff' },
          c = { fg = '#8B0000', bg = '#ffffff' },
        },
      },
      section_separators = '',
      component_separators = '',
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = { 'filename' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { 'filename' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
