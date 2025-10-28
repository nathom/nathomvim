local enable = require("nixCatsUtils").enableForCategory
local lazyAdd = require("nixCatsUtils").lazyAdd

return {
  {
    "mhinz/vim-sayonara",
    cmd = "Sayonara",
    enabled = enable("customNavigation", true),
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = { modes = { search = { enabled = true } } },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
    enabled = enable("customNavigation", true),
  },
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
    keys = { { "-", "<CMD>Oil<CR>", mode = { "n" }, desc = "Open parent directory" } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enabled = enable("customNavigation", true),
  },
}
