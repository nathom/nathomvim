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
		opts = {},
		config = function()
			require("oil").setup()
		end,
		keys = { { "-", "<CMD>Oil<CR>", mode = { "n" }, desc = "Open parent directory" } },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		enabled = enable("customNavigation", true),
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = lazyAdd("make"),
				cond = lazyAdd(function()
					return vim.fn.executable("make") == 1
				end),
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			local lga_actions = require("telescope-live-grep-args.actions")
			require("telescope").setup({
				defaults = {
					scroll_strategy = "cycle",
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						find_command = { "rg", "--files", "--hidden" },
					},
					git_files = { theme = "dropdown" },
					live_grep = {
						theme = "dropdown",
						additional_args = { "-j1" },
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					live_grep_args = {
						auto_quoting = true,
						mappings = {
							i = {
								["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
								["<C-space>"] = lga_actions.to_fuzzy_refine,
							},
						},
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "live_grep_args")

			local builtin = require("telescope.builtin")
			local utils = require("utils")
			local is_in_repo = utils.is_in_repo
			local function run_telescope_command()
				if is_in_repo() then
					builtin.git_files()
				else
					builtin.find_files()
				end
			end
			-- vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			-- vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			-- vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			-- vim.keymap.set("n", "<C-p>", run_telescope_command, { desc = "[S]earch (Git) [F]iles" })
			-- vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			-- vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<leader>sg",
			-- 	require("telescope").extensions.live_grep_args.live_grep_args,
			-- 	{ desc = "[S]earch by [G]rep with args" }
			-- )
			-- vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			-- vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			-- vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			-- vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			--
			-- vim.keymap.set("n", "<leader>/", function()
			-- 	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			-- 		winblend = 10,
			-- 		previewer = false,
			-- 	}))
			-- end, { desc = "[/] Fuzzily search in current buffer" })
			--
			-- vim.keymap.set("n", "<leader>s/", function()
			-- 	builtin.live_grep({
			-- 		grep_open_files = true,
			-- 		prompt_title = "Live Grep in Open Files",
			-- 	})
			-- end, { desc = "[S]earch [/] in Open Files" })
			--
			-- vim.keymap.set("n", "<leader>sn", function()
			-- 	builtin.find_files({ cwd = vim.fn.stdpath("config") })
			-- end, { desc = "[S]earch [N]eovim files" })
		end,
		enabled = enable("customNavigation", true),
	},
}
