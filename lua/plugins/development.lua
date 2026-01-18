local nixcats_utils = require("nixCatsUtils")
local enable = nixcats_utils.enableForCategory
local lazyAdd = nixcats_utils.lazyAdd
local isNixCats = nixcats_utils.isNixCats

return {
  {
    "neovim/nvim-lspconfig",
    enabled = enable("customLsp", true),
    dependencies = {
      {
        "williamboman/mason.nvim",
        enabled = lazyAdd(true, false),
        config = true,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        enabled = lazyAdd(true, false),
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        enabled = lazyAdd(true, false),
      },
      { "j-hui/fidget.nvim", opts = {} },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        enabled = enable("lang-lua", true),
        opts = {
          library = {
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

          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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

      -- Build servers table based on enabled language categories
      local servers = {}

      if nixCats("lang-lua") then
        servers.lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "nixCats" }, disable = { "missing-fields" } },
            },
          },
        }
      end

      if nixCats("lang-python") then
        servers.pyright = {}
      end

      if nixCats("lang-rust") then
        servers.rust_analyzer = {}
      end

      if nixCats("lang-nix") then
        if isNixCats then
          servers.nixd = {}
        else
          servers.nil_ls = {}
        end
      end

      if nixCats("lang-go") then
        servers.gopls = {}
      end

      if nixCats("lang-haskell") then
        servers.hls = {
          cmd = { "haskell-language-server-wrapper", "--lsp", "+RTS", "-M4G", "-RTS" },
        }
      end

      if nixCats("lang-c") then
        servers.clangd = {}
      end

      if isNixCats then
        for server_name, cfg in pairs(servers) do
          vim.lsp.config(server_name, cfg)
          vim.lsp.enable(server_name)
        end
      else
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
          "stylua",
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
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    enabled = enable("customLsp", true),
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
    opts = function()
      local formatters = {}
      if nixCats("lang-lua") then formatters.lua = { "stylua" } end
      if nixCats("lang-python") then formatters.python = { "ruff_format" } end
      if nixCats("latex") then formatters.tex = { "tex-fmt" } end
      if nixCats("lang-go") then formatters.go = { "gofmt" } end

      return {
        notify_on_error = false,
        format_on_save = function(bufnr)
          local disable_filetypes = { c = true, cpp = true, haskell = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = formatters,
      }
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    name = "luasnip",
    lazy = true,
    build = lazyAdd((function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return
      end
      return "make install_jsregexp"
    end)()),
    opts = {
      enable_autosnippets = true,
      update_events = "TextChanged,TextChangedI",
    },
    config = function(_, opts)
      local luasnip = require("luasnip")
      luasnip.config.setup(opts)
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    enabled = enable("customLsp", true),
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

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
    "nvim-treesitter/nvim-treesitter",
    build = lazyAdd(":TSUpdate"),
    config = function()
      -- Build parser list based on enabled languages (non-nix only)
      local parsers = { "bash", "diff", "markdown", "vim", "vimdoc" }
      if not isNixCats then
        if nixCats("lang-lua") then vim.list_extend(parsers, { "lua", "luadoc" }) end
        if nixCats("lang-python") then table.insert(parsers, "python") end
        if nixCats("lang-rust") then table.insert(parsers, "rust") end
        if nixCats("lang-go") then table.insert(parsers, "go") end
        if nixCats("lang-c") then vim.list_extend(parsers, { "c", "cpp" }) end
        if nixCats("lang-nix") then table.insert(parsers, "nix") end
        if nixCats("lang-haskell") then table.insert(parsers, "haskell") end
        require("nvim-treesitter.install").prefer_git = true
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = lazyAdd(parsers),
        auto_install = lazyAdd(true, false),
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
    enabled = enable("customCore", true),
  },
}
