local enable = require("nixCatsUtils").enableForCategory
local octo_review = require("octo_review")

return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = octo_review.keys(),
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = octo_review.opts,
    enabled = enable("general", true),
  },
}
