local enable = require("nixCatsUtils").enableForCategory

return {
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = false,
        allow_on_markdown = true,
      })
      local luasnip = require("luasnip")
      luasnip.config.setup({
        enable_autosnippets = true,
        update_events = "TextChanged,TextChangedI",
      })
    end,
    requires = { "L3MON4D3/LuaSnip" },
    ft = "tex",
    after = "LuaSnip",
    enabled = enable("customLatex", true),
  },
  {
    "lervag/vimtex",
    init = function()
      local opt = require("utils").opt
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "skim"
      vim.g.quickfix_mode = 0
      opt("conceallevel", 1)
      vim.g.tex_conceal = "abdmg"
    end,
    config = function()
      -- vim.g.vimtex_compiler_method = "generic"
      -- vim.g.vimtex_compiler_generic = {}
      -- vim.cmd([[call vimtex#compiler#generic#init({'name': 'pdflatex', 'continuous': 0})]])
    end,
    enabled = enable("customLatex", true),
  },
}
