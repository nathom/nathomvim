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
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{
		"mhinz/vim-sayonara",
		cmd = "Sayonara",
	},

	-- NOTE: nixCats: nix downloads it with a different file name.
	{ "numToStr/Comment.nvim", name = "comment.nvim", opts = {} },
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"nathom/delphi.nvim",
		keys = {
			{ "<leader><cr>", "<Plug>(DelphiChatSend)", desc = "Delphi: send chat" },
			{ "<C-i>", "<Plug>(DelphiRewriteSelection)", mode = { "x", "s" }, desc = "Delphi: rewrite selection" },
			{ "<C-i>", "<Plug>(DelphiInsertAtCursor)", mode = { "n", "i" }, desc = "Delphi: insert at cursor" },
			{ "<leader>a", "<Plug>(DelphiRewriteAccept)", desc = "Delphi: accept rewrite" },
			{ "<leader>R", "<Plug>(DelphiRewriteReject)", desc = "Delphi: reject rewrite" },
		},
		cmd = { "Chat" },
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		opts = {
			chat = { default_model = "grok4_fast" },
			rewrite = { default_model = "grok4_fast" },
			allow_env_var_config = true,
			models = {
				anduril_gpt_4o = {
					base_url = "https://alfred.itools.anduril.dev/raw",
					api_key_env_var = "ALFRED_API_KEY",
					model_name = "gpt-4o",
				},
				anduril_claude_35 = {
					base_url = "https://alfred.itools.anduril.dev/raw",
					api_key_env_var = "ALFRED_API_KEY",
					model_name = "anthropic.claude-3-5-sonnet-20240620-v1:0",
				},
				gemini_flash = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "google/gemini-2.5-flash",
				},
				grok4_fast = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "x-ai/grok-4-fast",
				},
				claude_37 = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "anthropic/claude-3.7-sonnet",
				},
				qwen3_14b = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "qwen/qwen3-14b",
				},
				qwen3_8b = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "qwen/qwen3-8b",
				},
				kimi_k2 = {
					base_url = "https://openrouter.ai/api/v1",
					api_key_env_var = "OPENROUTER_API_KEY",
					model_name = "moonshotai/kimi-k2",
				},
			},
		},
	},
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
		enabled = true,
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
		config = function(plugin)

			-- vim.g.vimtex_compiler_method = "generic"
			-- vim.g.vimtex_compiler_generic = {
			-- }
			-- vim.cmd([[call vimtex#compiler#generic#init({'name': 'pdflatex', 'continuous': 0})]])
		end,
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
	},
	{
		"chaoren/vim-wordmotion",
		keys = {
			{ "w", mode = "n" },
			{ "b", mode = "n" },
			{ "W", mode = "n" },
			{ "B", mode = "n" },
			{ "w", mode = "o" },
			{ "W", mode = "o" },
		},
	},
	{
		"romainl/vim-cool",
		keys = { "/", "?", "*", "#" },
	},
	{
		"stevearc/oil.nvim",
		opts = {},
		config = function()
			require("oil").setup()
		end,
		keys = { { "-", "<CMD>Oil<CR>", mode = { "n" }, desc = "Open parent directory" } },
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},


	{
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		config = function() -- This is the function that runs, AFTER loading
			require("which-key").setup()

			require("which-key").add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>d_", hidden = true },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>w_", hidden = true },
				{
					mode = { "v" },
					{ "<leader>h", group = "Git [H]unk" },
					{ "<leader>h_", hidden = true },
				},
			})
		end,
	},


	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",

				-- because nix already did this.
				build = require("nixCatsUtils").lazyAdd("make"),

				-- because nix built it already, so who cares if we have make in the path.
				cond = require("nixCatsUtils").lazyAdd(function()
					return vim.fn.executable("make") == 1
				end),
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },

			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()

			-- [[ Configure Telescope ]]
			local lga_actions = require("telescope-live-grep-args.actions")
			require("telescope").setup({
				defaults = {
					scroll_strategy = "cycle",
					-- 	"rg",
					-- 	"--color=never",
					-- 	"--no-heading",
					-- 	"--with-filename",
					-- 	"--line-number",
					-- 	"--column",
					-- 	"--smart-case",
					-- 	"--hidden",
					-- 	"-g '!.git'",
					-- },
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						find_command = { "rg", "--files", "--hidden" },
					},
					git_files = {
						theme = "dropdown",
					},
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
						auto_quoting = true, -- enable/disable auto-quoting
						mappings = { -- extend mappings
							i = {
								-- ["<C-q>"] = lga_actions.quote_prompt(),
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
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<C-p>", run_telescope_command, { desc = "[S]earch (Git) [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			-- vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set(
				"n",
				"<leader>sg",
				require("telescope").extensions.live_grep_args.live_grep_args,
				{ desc = "[S]earch by [G]rep with args" }
			)
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{ -- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason.nvim",
				-- because we will be using nix to download things instead.
				enabled = require("nixCatsUtils").lazyAdd(true, false),
				config = true,
			},
			{
				"williamboman/mason-lspconfig.nvim",
				-- because we will be using nix to download things instead.
				enabled = require("nixCatsUtils").lazyAdd(true, false),
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				-- because we will be using nix to download things instead.
				enabled = require("nixCatsUtils").lazyAdd(true, false),
			},

			{ "j-hui/fidget.nvim", opts = {} },

			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						-- adds type hints for nixCats global
						{ path = (nixCats.nixCatsPath or "") .. "/lua", words = { "nixCats" } },
					},
				},
			},
		},
		config = function()

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					map("K", vim.lsp.buf.hover, "Hover Documentation")

					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			vim.lsp.config("*", { capabilities = capabilities })

			-- NOTE: nixCats: there is help in nixCats for lsps at `:h nixCats.LSPs` and also `:h nixCats.luaUtils`
			local servers = {}
			servers.hls = {
				-- Limit memory use to 4 GB. This lsp has major mem leak issues.
				cmd = { "haskell-language-server-wrapper", "--lsp", "+RTS", "-M4G", "-RTS" },
			}
			servers.pyright = {}
			-- 			},
			-- 		},
			-- 	},
			-- }
			servers.rust_analyzer = {}

			-- NOTE: nixCats: nixd is not available on mason.
			-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
			if require("nixCatsUtils").isNixCats then
				servers.nixd = {}
			else
				servers.rnix = {}
				servers.nil_ls = {}
			end
			servers.lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "nixCats" },
							disable = { "missing-fields" },
						},
					},
				},
			}

			-- You could MAKE it work, using lspsAndRuntimeDeps and sharedLibraries in nixCats
			if require("nixCatsUtils").isNixCats then
				for server_name, cfg in pairs(servers) do
					vim.lsp.config(server_name, cfg)
					vim.lsp.enable(server_name)
				end
			else
				-- NOTE: nixCats: and if no nix, use mason

				local types = { "Error", "Warn", "Hint", "Info" }
				local signs = {}
				for _, type in ipairs(types) do
					signs[type] = "■■"
				end

				local utils = require("utils")
				local colors = utils.colors
				local sethl = utils.sethl
				sethl("DiagnosticError", colors.red, colors.darkgray)
				sethl("DiagnosticWarn", colors.yellow, colors.darkgray)
				sethl("DiagnosticHint", colors.cyan, colors.darkgray)
				sethl("DiagnosticInfo", colors.white, colors.darkgray)

				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
				end
				require("mason").setup()

				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					"stylua", -- Used to format Lua code
				})
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

				require("mason-lspconfig").setup({
					handlers = {
						function(server_name)
							vim.lsp.config(server_name, servers[server_name] or {})
							vim.lsp.enable(server_name)
						end,
					},
				})
			end
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true, haskell = true }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format", "ruff_organize_imports" },
				tex = { "tex-fmt" },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				-- NOTE: nixCats: nix downloads it with a different file name.
				name = "luasnip",
				build = require("nixCatsUtils").lazyAdd((function()
					-- Build Step is needed for regex support in snippets.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)()),
				dependencies = {
					-- {
					-- },
				},
			},
			"saadparwaiz1/cmp_luasnip",

			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({
				enable_autosnippets = true,
				update_events = "TextChanged,TextChangedI",
			})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				mapping = cmp.mapping.preset.insert({
					["<Down>"] = cmp.mapping.select_next_item(),
					["<Up>"] = cmp.mapping.select_prev_item(),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					["<Right>"] = cmp.mapping.confirm({ select = true }),

					--['<CR>'] = cmp.mapping.confirm { select = true },
					--['<Tab>'] = cmp.mapping.select_next_item(),
					--['<S-Tab>'] = cmp.mapping.select_prev_item(),

					["<C-Space>"] = cmp.mapping.complete({}),

					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
				performance = {
					max_view_entries = 12,
				},
			})
		end,
	},

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			vim.cmd.colorscheme("gruvbox")

			vim.cmd.hi("Comment gui=none")
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
			})
		end,
	},
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })

			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

		end,
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = require("nixCatsUtils").lazyAdd(":TSUpdate"),
		opts = {
			-- because nix already ensured they were installed.
			ensure_installed = require("nixCatsUtils").lazyAdd({
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"vim",
				"vimdoc",
			}),
			auto_install = require("nixCatsUtils").lazyAdd(true, false),

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)

			require("nvim-treesitter.install").prefer_git = true
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup(opts)

		end,
	},


	-- This is because within them, we used nixCats to check if it should be loaded!
	require("kickstart.plugins.debug"),
	require("kickstart.plugins.indent_line"),
	require("kickstart.plugins.lint"),
	require("kickstart.plugins.autopairs"),
	require("kickstart.plugins.neo-tree"),
	require("kickstart.plugins.gitsigns"), -- adds gitsigns recommend keymaps

	{ import = "custom.plugins" },
}, lazyOptions)
