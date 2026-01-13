local enable = require("nixCatsUtils").enableForCategory

return {
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = false,
        allow_on_markdown = true,
      })
    end,
    dependencies = { "L3MON4D3/LuaSnip" },
    ft = "tex",
    enabled = enable("customLatex", true),
  },
  {
    "lervag/vimtex",
    ft = { "tex", "bib" },
    init = function()
      local opt = require("utils").opt
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "skim"
      vim.g.quickfix_mode = 0
      opt("conceallevel", 1)
      vim.g.tex_conceal = "abdmg"
    end,
    config = function()
      -- Hide LaTeX auxiliary files after successful compile (macOS)
      vim.api.nvim_create_autocmd("User", {
        pattern = "VimtexEventCompileSuccess",
        callback = function()
          local dir = vim.fn.expand("%:p:h")
          local exts = { "aux", "log", "fls", "fdb_latexmk", "synctex.gz", "out", "toc" }
          for _, ext in ipairs(exts) do
            for _, f in ipairs(vim.fn.glob(dir .. "/*." .. ext, false, true)) do
              vim.fn.system({ "chflags", "hidden", f })
            end
          end
        end,
      })
    end,
    enabled = enable("customLatex", true),
  },
}
