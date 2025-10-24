--[[
 _ __   __ _| |_| |__   ___  _ __ _____   _(_)_ __ ___
| '_ \ / _` | __| '_ \ / _ \| '_ ` _ \ \ / / | '_ ` _ \
| | | | (_| | |_| | | | (_) | | | | | \ V /| | | | | | |
|_| |_|\__,_|\__|_| |_|\___/|_| |_| |_|\_/ |_|_| |_| |_|
--]]

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
	"gzip",
	"man",
	"matchit",
	"matchparen",
	"shada_plugin",
	"tarPlugin",
	"tar",
	"zipPlugin",
	"zip",
	"netrwPlugin",
	"2html_plugin",
	"remote_plugins",
}

for _, plugin in ipairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- Speed up startup time
-- Doesn't work with vim.opt for some reason
vim.cmd([[set shada="NONE"]])

require("nixCatsUtils").setup({
	non_nix_value = true,
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Set to true if you have a Nerd Font installed and selected in the terminal
-- NOTE: nixCats: we asked nix if we have it instead of setting it here.
-- because nix is more likely to know if we have a nerd font or not.
vim.g.have_nerd_font = nixCats("have_nerd_font")

-- [[ Setting options ]]

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"
vim.opt.swapfile = false

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "L", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<localleader>w", function()
	vim.cmd([[w!]])
end, { desc = "Open diagnostic [Q]uickfix list" })
vim.cmd([[command! Q qa!]])

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<localleader>q", "<cmd>Sayonara<cr>")

-- [[ Basic Autocommands ]]

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.opt.autowriteall = true

-- Write all modified real files when Neovim loses focus (e.g., you switch tmux panes)
local grp = vim.api.nvim_create_augroup("AutosaveOnBlur", { clear = true })
vim.api.nvim_create_autocmd("FocusLost", {
	group = grp,
	callback = function()
		pcall(vim.cmd, "silent! wall") -- no noise on special buffers
	end,
})

local function getlockfilepath()
	if require("nixCatsUtils").isNixCats and type(nixCats.settings.unwrappedCfgPath) == "string" then
		return nixCats.settings.unwrappedCfgPath .. "/lazy-lock.json"
	else
		return vim.fn.stdpath("config") .. "/lazy-lock.json"
	end
end
local lazyOptions = {
	lockfile = getlockfilepath(),
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
}

-- [[ Configure and install plugins ]]
-- NOTE: nixCats: this the lazy wrapper. Use it like require('lazy').setup() but with an extra
-- argument, the path to lazy.nvim as downloaded by nix, or nil, before the normal arguments.
require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), {
	{ import = "custom.plugins.core" },
	{ import = "custom.plugins.navigation" },
	{ import = "custom.plugins.git" },
	{ import = "custom.plugins.development" },
	{ import = "custom.plugins.latex" },
	{ import = "custom.plugins.ai" },

	-- This is because within them, we used nixCats to check if it should be loaded!
	require("kickstart.plugins.debug"),
	require("kickstart.plugins.indent_line"),
	require("kickstart.plugins.lint"),
	require("kickstart.plugins.autopairs"),
	require("kickstart.plugins.neo-tree"),
	require("kickstart.plugins.gitsigns"), -- adds gitsigns recommend keymaps
}, lazyOptions)
