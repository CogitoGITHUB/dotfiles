-- /011 treesitter.lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    -- Check if treesitter is available
    local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
    if not status_ok then
      vim.notify('Treesitter not loaded yet. Please run :Lazy sync', vim.log.levels.WARN)
      return
    end

    treesitter.setup({
      ensure_installed = {
        'lua', 'vim', 'vimdoc', 'query',
        'python', 'javascript', 'typescript',
        'html', 'css', 'json', 'yaml',
        'bash', 'markdown', 'latex',
        'c', 'cpp', 'rust', 'go',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<BS>',
        },
      },
    })
  end,
}
