return {
  'lervag/vimtex',
  ft = { 'tex', 'bib' },
  config = function()
    -- Zathura viewer
    vim.g.vimtex_view_method = 'zathura'
    
    -- Compiler settings
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      build_dir = '',
      callback = 1,
      continuous = 1,
      executable = 'latexmk',
      options = {
        '-pdf',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      },
    }
    
    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 0
    
    -- Enable folding
    vim.g.vimtex_fold_enabled = 1
    
    -- Syntax concealment
    vim.opt.conceallevel = 2
    vim.g.vimtex_syntax_conceal_default = 1

    -- Custom keymaps (use your leader key)
    vim.keymap.set('n', '<leader>lc', '<cmd>VimtexCompile<cr>', { desc = 'VimTeX Compile' })
    vim.keymap.set('n', '<leader>lv', '<cmd>VimtexView<cr>', { desc = 'VimTeX View' })
    vim.keymap.set('n', '<leader>ls', '<cmd>VimtexStop<cr>', { desc = 'VimTeX Stop' })
    vim.keymap.set('n', '<leader>le', '<cmd>VimtexErrors<cr>', { desc = 'VimTeX Errors' })
    vim.keymap.set('n', '<leader>li', '<cmd>VimtexInfo<cr>', { desc = 'VimTeX Info' })
  end,
}
