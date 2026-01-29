return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      theme = {
        normal = {
          a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
        },
        insert = {
          a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
        },
        visual = {
          a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
        },
        replace = {
          a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
        },
        command = {
          a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
        },
        inactive = {
          a = { fg = '#000000', bg = '#ffffff' },
          b = { fg = '#000000', bg = '#ffffff' },
          c = { fg = '#000000', bg = '#ffffff' },
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
