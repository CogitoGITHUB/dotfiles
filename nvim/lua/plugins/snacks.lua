return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    -- Dashboard
    { "<leader>.", function() Snacks.dashboard() end, desc = "Dashboard" },
    
    -- Explorer (file tree)
    { "<leader>fe", function() Snacks.explorer() end, desc = "Explorer (snacks)" },
    
    -- Picker (fuzzy finder)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fgc", function() Snacks.picker.git_status() end, desc = "Git Status" },
    
    -- Git
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    
    -- Notifications
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
    
    -- Terminal
    { "<leader>tt", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<leader>tg", function() Snacks.lazygit() end, desc = "Lazygit" },
    
    -- Scratch (temporary buffers)
    { "<leader>bs", function() Snacks.scratch() end, desc = "Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch" },
    
    -- Rename
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    
    -- Zen mode
    { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },
    { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Zen Zoom" },
    
    -- Words (highlight word under cursor)
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
  },
  
  opts = {
    -- ===== BIGFILE =====
    bigfile = { 
      enabled = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
    },
    
    -- ===== DASHBOARD =====
    dashboard = {
      enabled = true,
      preset = {
        header = [[
 ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
 ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    
    -- ===== EXPLORER =====
    explorer = {
      enabled = true,
    },
    
    -- ===== INDENT =====
    indent = {
      enabled = true,
      char = "│",
      blank = " ",
    },
    
    -- ===== INPUT =====
    input = {
      enabled = true,
    },
    
    -- ===== PICKER =====
    picker = {
      enabled = true,
    },
    
    -- ===== NOTIFIER =====
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    
    -- ===== QUICKFILE =====
    quickfile = { 
      enabled = true 
    },
    
    -- ===== SCOPE =====
    scope = {
      enabled = true,
    },
    
    -- ===== SCROLL =====
    scroll = {
      enabled = true,
    },
    
    -- ===== STATUSCOLUMN =====
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" },
      right = { "fold", "git" },
    },
    
    -- ===== WORDS =====
    words = {
      enabled = true,
      debounce = 200,
    },
    
    -- ===== ADDITIONAL FEATURES =====
    git = { enabled = true },
    gitbrowse = { enabled = true },
    lazygit = { 
      enabled = true,
    },
    rename = { enabled = true },
    scratch = { 
      enabled = true,
    },
    terminal = {
      enabled = true,
    },
    toggle = { enabled = true },
    zen = {
      enabled = true,
    },
  },
  
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup notification redirect
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd
      end,
    })
  end,
}
