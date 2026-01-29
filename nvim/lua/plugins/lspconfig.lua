-- /009 lspconfig.lua
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    -- Setup mason first
    require('mason').setup({
      ui = {
        border = 'rounded',
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })
    
    -- Mason-lspconfig setup
    require('mason-lspconfig').setup({
      ensure_installed = {
        'lua_ls',
        'texlab',
        'pyright',
        'ts_ls',
      },
      automatic_installation = true,
    })
    
    -- Capabilities for nvim-cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- LSP keymaps (applied when LSP attaches)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>f', function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      end,
    })
    
    -- Configure servers using new vim.lsp.config
    vim.lsp.config('*', {
      capabilities = capabilities,
    })
    
    -- LaTeX (texlab)
    vim.lsp.config.texlab = {
      cmd = { 'texlab' },
      filetypes = { 'tex', 'bib' },
      root_markers = { '.latexmkrc', '.git' },
      settings = {
        texlab = {
          auxDirectory = ".",
          bibtexFormatter = "texlab",
          build = {
            args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
            executable = "latexmk",
            forwardSearchAfter = false,
            onSave = false,
          },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
          formatterLineLength = 80,
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = false,
          },
        }
      }
    }
    
    -- Lua
    vim.lsp.config.lua_ls = {
      cmd = { 'lua-language-server' },
      filetypes = { 'lua' },
      root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        }
      }
    }
    
    -- Python
    vim.lsp.config.pyright = {
      cmd = { 'pyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = { 'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    }
    
    -- TypeScript/JavaScript
    vim.lsp.config.ts_ls = {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
      root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    }
    
    -- Enable servers
    vim.lsp.enable('texlab')
    vim.lsp.enable('lua_ls')
    vim.lsp.enable('pyright')
    vim.lsp.enable('ts_ls')
    
    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = 'rounded',
        source = 'always',
      },
    })
    
    -- Diagnostic signs
    local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
  end,
}
