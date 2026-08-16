local M = {}

local function map(lhs, desc, mode)
  return { lhs = lhs, desc = desc, mode = mode }
end

function M.proxy_env(env)
  return {
    http_proxy = env.http_proxy or env.HTTP_PROXY,
    https_proxy = env.https_proxy or env.HTTPS_PROXY,
    no_proxy = env.no_proxy or env.NO_PROXY,
  }
end

function M.opts()
  return {
    picker = "snacks",
    enable_builtin = true,
    default_merge_method = "squash",
    mappings_disable_default = true,
    picker_config = {
      mappings = {
        open_in_browser = map("<leader>pb", "Open in browser"),
        copy_url = map("<leader>py", "Copy URL"),
        copy_sha = map("<leader>ph", "Copy head SHA"),
        checkout_pr = map("<leader>po", "Checkout PR"),
        merge_pr = map("<leader>pM", "Squash merge PR"),
      },
    },
    gh_env = function()
      return M.proxy_env(vim.env)
    end,
    colors = {
      white = "#ebdbb2",
      grey = "#928374",
      black = "#282828",
      red = "#fb4934",
      dark_red = "#cc241d",
      green = "#b8bb26",
      dark_green = "#98971a",
      yellow = "#fabd2f",
      dark_yellow = "#d79921",
      blue = "#83a598",
      dark_blue = "#458588",
      purple = "#b16286",
    },
    reviews = {
      auto_show_threads = true,
      focus = "right",
      show_virtual_text = true,
    },
    ui = {
      conceallevel = 2,
      use_signcolumn = true,
      use_statuscolumn = false,
      use_foldtext = true,
    },
    pull_requests = {
      order_by = { field = "UPDATED_AT", direction = "DESC" },
    },
    file_panel = {
      size = 12,
      icons = true,
    },
    mappings = {
      pull_request = {
        pr_options = map("<leader>pa", "PR actions"),
        checkout_pr = map("<leader>po", "Checkout PR"),
        squash_and_merge_pr = map("<leader>pM", "Squash merge PR"),
        list_commits = map("<leader>pC", "PR commits"),
        list_changed_files = map("<leader>pf", "PR changed files"),
        show_pr_diff = map("<leader>pd", "PR diff"),
        add_reviewer = map("<leader>pv", "Add reviewer"),
        remove_reviewer = map("<leader>pV", "Remove reviewer"),
        close_issue = map("<leader>px", "Close PR"),
        reopen_issue = map("<leader>pX", "Reopen PR"),
        reload = map("<leader>pR", "Reload PR"),
        open_in_browser = map("<leader>pb", "Open PR in browser"),
        copy_url = map("<leader>py", "Copy PR URL"),
        copy_sha = map("<leader>ph", "Copy head SHA"),
        goto_file = map("gf", "Open local file"),
        add_comment = map("<leader>pc", "Add PR comment"),
        delete_comment = map("<leader>pD", "Delete comment"),
        next_comment = map("]c", "Next comment"),
        prev_comment = map("[c", "Previous comment"),
        resolve_thread = map("<leader>pt", "Resolve thread"),
        unresolve_thread = map("<leader>pT", "Unresolve thread"),
      },
      review_diff = {
        submit_review = map("<leader>pS", "Submit review"),
        discard_review = map("<leader>pD", "Discard review"),
        add_review_comment = map("<leader>pc", "Add review comment", { "n", "x" }),
        add_review_suggestion = map("<leader>pg", "Add review suggestion", { "n", "x" }),
        focus_files = map("<leader>pe", "Focus changed files"),
        toggle_files = map("<leader>pE", "Toggle changed files"),
        next_thread = map("]t", "Next review thread"),
        prev_thread = map("[t", "Previous review thread"),
        select_next_entry = map("]f", "Next changed file"),
        select_prev_entry = map("[f", "Previous changed file"),
        select_first_entry = map("[F", "First changed file"),
        select_last_entry = map("]F", "Last changed file"),
        select_next_unviewed_entry = map("]u", "Next unviewed file"),
        select_prev_unviewed_entry = map("[u", "Previous unviewed file"),
        close_review_tab = map("<leader>pq", "Close review"),
        toggle_viewed = map("<leader>pv", "Toggle file viewed"),
        goto_file = map("gf", "Open local file"),
        copy_sha = map("<leader>ph", "Copy head SHA"),
        review_commits = map("<leader>pC", "Review commits"),
      },
      review_thread = {
        add_reply = map("<leader>pc", "Reply to thread"),
        add_suggestion = map("<leader>pg", "Add suggestion"),
        delete_comment = map("<leader>pD", "Delete comment"),
        next_comment = map("]c", "Next comment"),
        prev_comment = map("[c", "Previous comment"),
        select_next_entry = map("]f", "Next changed file"),
        select_prev_entry = map("[f", "Previous changed file"),
        select_first_entry = map("[F", "First changed file"),
        select_last_entry = map("]F", "Last changed file"),
        select_next_unviewed_entry = map("]u", "Next unviewed file"),
        select_prev_unviewed_entry = map("[u", "Previous unviewed file"),
        close_review_tab = map("<leader>pq", "Close review"),
        resolve_thread = map("<leader>pt", "Resolve thread"),
        unresolve_thread = map("<leader>pT", "Unresolve thread"),
      },
      submit_win = {
        approve_review = map("<leader>pa", "Approve review", { "n" }),
        comment_review = map("<leader>pc", "Submit review comment", { "n" }),
        request_changes = map("<leader>pr", "Request changes", { "n" }),
        close_review_tab = map("<leader>pq", "Cancel review submission", { "n" }),
      },
      file_panel = {
        submit_review = map("<leader>pS", "Submit review"),
        discard_review = map("<leader>pD", "Discard review"),
        next_entry = map("j", "Next changed file"),
        prev_entry = map("k", "Previous changed file"),
        select_entry = map("<CR>", "Open changed file"),
        refresh_files = map("R", "Refresh changed files"),
        focus_files = map("<leader>pe", "Focus changed files"),
        toggle_files = map("<leader>pE", "Toggle changed files"),
        select_next_entry = map("]f", "Next changed file"),
        select_prev_entry = map("[f", "Previous changed file"),
        select_first_entry = map("[F", "First changed file"),
        select_last_entry = map("]F", "Last changed file"),
        select_next_unviewed_entry = map("]u", "Next unviewed file"),
        select_prev_unviewed_entry = map("[u", "Previous unviewed file"),
        close_review_tab = map("<leader>pq", "Close review"),
        toggle_viewed = map("<leader>pv", "Toggle file viewed"),
        review_commits = map("<leader>pC", "Review commits"),
      },
    },
  }
end

function M.keys()
  return {
    { "<leader>pp", "<cmd>Octo pr list<cr>", desc = "Pull requests" },
    { "<leader>pn", "<cmd>Octo notification list<cr>", desc = "GitHub notifications" },
    { "<leader>po", "<cmd>Octo<cr>", desc = "Octo command palette" },
    { "<leader>pa", "<cmd>Octo actions<cr>", desc = "Octo actions" },
    { "<leader>ps", "<cmd>Octo review<cr>", desc = "Start or resume review" },
    { "<leader>pS", "<cmd>Octo review submit<cr>", desc = "Submit review" },
  }
end

return M
