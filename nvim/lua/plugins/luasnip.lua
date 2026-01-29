-- /007 luasnip.lua
return {
  'L3MON4D3/LuaSnip',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    local ls = require('luasnip')
    
    -- Load friendly snippets
    require('luasnip.loaders.from_vscode').lazy_load()
    
    -- Keymaps
    vim.keymap.set({'i', 's'}, '<C-k>', function() ls.expand() end, {silent = true})
    vim.keymap.set({'i', 's'}, '<C-l>', function() ls.jump(1) end, {silent = true})
    vim.keymap.set({'i', 's'}, '<C-h>', function() ls.jump(-1) end, {silent = true})
    
    -- LaTeX snippets
    ls.add_snippets('tex', {
      ls.snippet('beg', {
        ls.text_node('\\begin{'),
        ls.insert_node(1, 'environment'),
        ls.text_node({'}', '', '\t'}),  -- Fixed: changed '}' to '}'
        ls.insert_node(0),
        ls.text_node({'', '\\end{'}),
        ls.function_node(function(args) return args[1][1] end, {1}),
        ls.text_node('}'),
      }),
      ls.snippet('frac', {
        ls.text_node('\\frac{'),
        ls.insert_node(1),
        ls.text_node('}{'),
        ls.insert_node(2),
        ls.text_node('}'),
        ls.insert_node(0),
      }),
      ls.snippet('eq', {
        ls.text_node({'\\begin{equation}', '\t'}),
        ls.insert_node(0),
        ls.text_node({'', '\\end{equation}'}),
      }),
    })
  end,
}
