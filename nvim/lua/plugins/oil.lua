return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>e', '<cmd>Oil<cr>', desc = 'Open file explorer' },
    { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
  opts = {
    -- Show hidden files (dotfiles)
    view_options = {
      show_hidden = true,
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function(name, bufnr)
        return false
      end,
    },
    
    -- Skip confirmation for simple edits
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
    
    -- Trash instead of permanent delete
    delete_to_trash = true,
    
    -- Show file icons
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    
    -- Buffer options
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    
    -- Window options
    win_options = {
      wrap = false,
      signcolumn = "yes:2",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },
    
    -- Use default keymaps
    use_default_keymaps = true,
    
    -- Extra keymaps
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-r>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",  -- Toggle hidden files
      ["g\\"] = "actions.toggle_trash",
    },
    
    -- Float window settings (if you prefer floating window)
    float = {
      padding = 2,
      max_width = 90,
      max_height = 30,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
    
    -- Confirmation settings
    confirmation = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      max_height = 0.9,
      min_height = { 5, 0.1 },
      border = "rounded",
    },
    
    -- Progress window
    progress = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      max_height = { 10, 0.9 },
      min_height = { 5, 0.1 },
      border = "rounded",
      minimized_border = "none",
      win_options = {
        winblend = 0,
      },
    },
  },
}
