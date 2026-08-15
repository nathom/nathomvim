local M = {}

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function command_error(result)
  local message = trim(result.stderr ~= "" and result.stderr or result.stdout)
  return message ~= "" and message or ("command failed with exit code %s"):format(result.code)
end

local function defaults()
  return {
    run = function(args, cwd, callback)
      vim.system(args, { cwd = cwd, text = true }, function(result)
        vim.schedule(function()
          callback(result)
        end)
      end)
    end,
    decode = vim.json.decode,
    write_all = function()
      return pcall(vim.cmd, "wall")
    end,
    checktime = function()
      vim.cmd("checktime")
      local ok, gitsigns = pcall(require, "gitsigns")
      if ok then
        gitsigns.refresh()
      end
    end,
    notify = function(message, level)
      local levels = {
        error = vim.log.levels.ERROR,
        info = vim.log.levels.INFO,
        warn = vim.log.levels.WARN,
      }
      vim.notify(message, levels[level] or vim.log.levels.INFO, { title = "GitHub PR" })
    end,
  }
end

function M._items(pages)
  if pages[1] and pages[1].number then
    pages = { pages }
  end

  local items = {}
  for _, page in ipairs(pages) do
    for _, pr in ipairs(page) do
      local author = pr.user and pr.user.login or "unknown"
      local branch = pr.head and pr.head.ref or "unknown"
      local title = tostring(pr.title or ""):gsub("%s+", " ")
      items[#items + 1] = {
        number = pr.number,
        text = ("#%d  %s  @%s  %s"):format(pr.number, title, author, branch),
      }
    end
  end
  return items
end

function M._list(root, overrides, callback)
  local deps = overrides or defaults()
  deps.run(
    {
      "gh",
      "api",
      "--method",
      "GET",
      "--paginate",
      "--slurp",
      "repos/{owner}/{repo}/pulls?state=open&per_page=100",
    },
    root,
    function(result)
      if result.code ~= 0 then
        deps.notify("Failed to list pull requests: " .. command_error(result), "error")
        return
      end

      local ok, pages = pcall(deps.decode, result.stdout)
      if not ok or type(pages) ~= "table" then
        deps.notify("Failed to parse pull requests from gh api", "error")
        return
      end
      callback(M._items(pages))
    end
  )
end

function M._checkout(root, pr, overrides)
  local deps = overrides or defaults()
  local wrote, write_error = deps.write_all()
  if not wrote then
    deps.notify("Failed to save modified buffers: " .. tostring(write_error), "error")
    return
  end

  local function checkout(stashed)
    deps.run({ "gh", "pr", "checkout", tostring(pr.number) }, root, function(result)
      if result.code == 0 then
        deps.checktime()
        local suffix = stashed and "; previous working changes are stashed at stash@{0}" or ""
        deps.notify(("Checked out PR #%d%s"):format(pr.number, suffix), "info")
        return
      end

      local checkout_error = command_error(result)
      if not stashed then
        deps.notify(("Failed to checkout PR #%d: %s"):format(pr.number, checkout_error), "error")
        return
      end

      deps.run({ "git", "stash", "pop", "--index", "stash@{0}" }, root, function(restore_result)
        if restore_result.code == 0 then
          deps.notify(
            ("Failed to checkout PR #%d: %s; autostashed changes were restored"):format(pr.number, checkout_error),
            "error"
          )
        else
          deps.notify(
            ("Failed to checkout PR #%d: %s; autostash remains at stash@{0} because restore failed: %s"):format(
              pr.number,
              checkout_error,
              command_error(restore_result)
            ),
            "error"
          )
        end
      end)
    end)
  end

  deps.run({ "git", "status", "--porcelain=v1", "--untracked-files=all" }, root, function(result)
    if result.code ~= 0 then
      deps.notify("Failed to inspect working changes: " .. command_error(result), "error")
      return
    end

    if trim(result.stdout) == "" then
      checkout(false)
      return
    end

    deps.run(
      {
        "git",
        "stash",
        "push",
        "--include-untracked",
        "-m",
        ("nvim: before checkout of PR #%d"):format(pr.number),
      },
      root,
      function(stash_result)
        if stash_result.code ~= 0 then
          deps.notify("Failed to autostash working changes: " .. command_error(stash_result), "error")
          return
        end
        checkout(true)
      end
    )
  end)
end

function M.pick()
  local deps = defaults()
  local cwd = vim.fn.getcwd()
  deps.run({ "git", "rev-parse", "--show-toplevel" }, cwd, function(result)
    if result.code ~= 0 then
      deps.notify("Current directory is not in a git repository: " .. command_error(result), "error")
      return
    end

    local root = trim(result.stdout)
    M._list(root, deps, function(items)
      if #items == 0 then
        deps.notify("No open pull requests", "info")
        return
      end

      Snacks.picker({
        title = "GitHub Pull Requests",
        items = items,
        format = "text",
        preview = "none",
        layout = { preset = "select" },
        confirm = function(picker, item)
          picker:close()
          if item then
            M._checkout(root, item, deps)
          end
        end,
      })
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("PrCheckout", M.pick, {
    desc = "Fuzzy-find and checkout a GitHub pull request",
  })
end

return M
