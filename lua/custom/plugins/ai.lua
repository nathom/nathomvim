local enable = require("nixCatsUtils").enableForCategory

return {
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
    enabled = enable("customAi", true),
  },
}
