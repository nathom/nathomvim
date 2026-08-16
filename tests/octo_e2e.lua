local function check(value, message)
  if not value then
    error(message, 2)
  end
end

require("lazy").load({ plugins = { "octo.nvim" } })

check(vim.fn.exists(":Octo") == 2, "Octo command was not registered")
check(vim.fn.maparg("<leader>pp", "n") ~= "", "<leader>pp was not registered")
check(vim.fn.maparg("<leader>ps", "n") ~= "", "smart start/resume mapping was not registered")
check(vim.fn.maparg("<leader>pS", "n") ~= "", "global review submit mapping was not registered")

local config = require("octo.config").values
check(config.picker == "snacks", "Octo is not using the Snacks picker")
check(config.mappings_disable_default == true, "Octo default mappings remain enabled")
check(config.mappings.submit_win.comment_review.lhs == "<leader>pc", "review comment still uses Ctrl-M")
check(vim.fn.hlexists("OctoGreen") == 1, "Octo theme highlights were not created")

print("Octo e2e configuration checks passed")
