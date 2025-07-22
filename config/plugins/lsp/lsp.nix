{ pkgs, ... }:
{
  plugins = {
    lsp-lines = {
      enable = true;
    };
    lsp-format = {
      enable = false;
    };
    helm = {
      enable = true;
    };
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        lua_ls = {
          enable = true;
        };
        pyright = {
          enable = true;
        };
        jsonls = {
          enable = true;
        };
        hls = {
          enable = true;
          installGhc = true;
        };
        nil_ls = {
          enable = true;
        };
      };

      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>rn" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          L = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "[d" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "]d" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
      };
    };
  };
  extraPlugins = with pkgs.vimPlugins; [
    ansible-vim
  ];

  extraConfigLua = ''
    local _border = "rounded"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with( vim.lsp.handlers.hover, { border = _border })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = _border
      }
    )

    vim.diagnostic.config{
      float={border=_border}
    };

    require('lspconfig.ui.windows').default_options = {
      border = _border
    }

    local utils = require("utils")
    local colors = utils.colors
    local sethl = utils.sethl
    local types = { "Error", "Warn", "Hint", "Info" }
    local signs = {}
    local sign_icon = ""
    for _, type in ipairs(types) do
        -- signs[type] = "■■"
        signs[type] = ""
        -- signs[type] = ""
        -- signs[type] = ""
        -- signs[type] = "••"
        -- signs[type] = ""
    end

    sethl("DiagnosticError", colors.red, colors.darkgray)
    sethl("DiagnosticWarn", colors.yellow, colors.darkgray)
    sethl("DiagnosticHint", colors.cyan, colors.darkgray)
    sethl("DiagnosticInfo", colors.white, colors.darkgray)

    vim.diagnostic.config({signs={
        text = {
            [vim.diagnostic.severity.ERROR] = sign_icon,
            [vim.diagnostic.severity.WARN] = sign_icon,
            [vim.diagnostic.severity.HINT] = sign_icon,
            [vim.diagnostic.severity.INFO] = sign_icon,
        }
    }})
    -- for type, icon in pairs(signs) do
    --     local hl = "DiagnosticSign" .. type
    --     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    -- end
  '';
}
