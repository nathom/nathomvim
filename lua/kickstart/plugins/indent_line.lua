return {
  {
    "lukas-reineke/indent-blankline.nvim",
    -- NOTE: nixCats: return true only if category is enabled, else false
    enabled = require("nixCatsUtils").enableForCategory("kickstart-indent_line"),
    main = "ibl",
    opts = {},
  },
}
