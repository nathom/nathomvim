local enable = require("nixCatsUtils").enableForCategory

return {
  {
    "nathom/delphi.nvim",
    keys = {
      {
        "<leader>dd",
        function()
          require("delphi").chat()
        end,
        desc = "Delphi: open chat",
      },
      {
        "<leader>df",
        function()
          require("delphi").chat_open_float()
        end,
        desc = "Delphi: open floating chat",
      },
      {
        "<leader>ds",
        function()
          require("delphi").open_chats_picker()
        end,
        desc = "Delphi: chats picker",
      },
      {
        "<leader>dg",
        function()
          require("delphi").grep_chats()
        end,
        desc = "Delphi: grep chats",
      },
      {
        "<leader>dr",
        function()
          require("delphi").rewrite_selection()
        end,
        mode = { "x", "s" },
        desc = "Delphi: rewrite selection",
      },
      {
        "<leader>dr",
        function()
          require("delphi").rewrite_at_cursor()
        end,
        mode = "n",
        desc = "Delphi: insert at cursor",
      },
      {
        "<C-i>",
        function()
          require("delphi").rewrite_at_cursor()
        end,
        mode = "i",
        desc = "Delphi: insert at cursor",
      },
      {
        "<leader>de",
        function()
          require("delphi").explain_selection()
        end,
        mode = { "x", "s" },
        desc = "Delphi: explain selection",
      },
      {
        "<leader>de",
        function()
          require("delphi").explain_at_cursor()
        end,
        mode = "n",
        desc = "Delphi: explain at cursor",
      },
      {
        "<leader>da",
        function()
          require("delphi").rewrite_accept()
        end,
        desc = "Delphi: accept rewrite",
      },
      {
        "<leader>dx",
        function()
          require("delphi").rewrite_reject()
        end,
        desc = "Delphi: reject rewrite",
      },
    },
    dependencies = { "folke/snacks.nvim" },
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
    enabled = enable("customAi", true),
  },
}
