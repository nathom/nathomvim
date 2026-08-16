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
        title = title,
        branch = branch,
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

function M._checkout(root, pr, overrides, progress)
  local deps = overrides or defaults()

  local function update(stage, status, detail)
    if progress then
      progress:update(stage, status, detail)
    end
  end

  local function finish(status, message, detail)
    if progress then
      progress:finish(status, message, detail)
      return
    end
    local suffix = detail and detail ~= "" and (": " .. detail) or ""
    deps.notify(message .. suffix, status == "success" and "info" or "error")
  end

  local function is_worktree_conflict(message)
    return message:find("already used by worktree", 1, true) or message:find("already checked out at", 1, true)
  end

  local function complete(stashed, detached)
    update("reload", "active")
    local refreshed, refresh_error = pcall(deps.checktime)
    update("reload", refreshed and "success" or "warning", refreshed and nil or refresh_error)
    local message = ("Checked out PR #%d%s"):format(pr.number, detached and " detached" or "")
    local detail = stashed and "Previous working changes are safely stashed at stash@{0}" or "Working tree was clean"
    finish("success", message, detail)
  end

  local function fail_checkout(stashed, checkout_error)
    if not stashed then
      finish("error", ("Could not checkout PR #%d"):format(pr.number), checkout_error)
      return
    end

    update("restore", "active")
    deps.run({ "git", "stash", "pop", "--index", "stash@{0}" }, root, function(restore_result)
      if restore_result.code == 0 then
        update("restore", "success")
        finish(
          "error",
          ("Could not checkout PR #%d"):format(pr.number),
          checkout_error .. "; autostashed changes were restored"
        )
        return
      end

      local restore_error = command_error(restore_result)
      update("restore", "error", restore_error)
      finish(
        "error",
        ("Could not checkout PR #%d"):format(pr.number),
        checkout_error .. "; stash@{0} was kept because restore failed: " .. restore_error
      )
    end)
  end

  local function checkout(stashed)
    update("checkout", "active")
    deps.run({ "gh", "pr", "checkout", tostring(pr.number) }, root, function(result)
      if result.code == 0 then
        update("checkout", "success")
        complete(stashed, false)
        return
      end

      local checkout_error = command_error(result)
      if is_worktree_conflict(checkout_error) then
        update("checkout", "warning", "Branch is active in another worktree")
        update("detached", "active")
        deps.run({ "gh", "pr", "checkout", tostring(pr.number), "--detach" }, root, function(detached_result)
          if detached_result.code == 0 then
            update("detached", "success")
            complete(stashed, true)
            return
          end
          local detached_error = command_error(detached_result)
          update("detached", "error", detached_error)
          fail_checkout(stashed, detached_error)
        end)
        return
      end

      update("checkout", "error", checkout_error)
      fail_checkout(stashed, checkout_error)
    end)
  end

  update("save", "active")
  local wrote, write_error = deps.write_all()
  if not wrote then
    update("save", "error", write_error)
    finish("error", "Could not save modified buffers", write_error)
    return
  end
  update("save", "success")

  update("inspect", "active")
  deps.run({ "git", "status", "--porcelain=v1", "--untracked-files=all" }, root, function(result)
    if result.code ~= 0 then
      local inspect_error = command_error(result)
      update("inspect", "error", inspect_error)
      finish("error", "Could not inspect working changes", inspect_error)
      return
    end

    if trim(result.stdout) == "" then
      update("inspect", "success", "Clean")
      update("stash", "skipped", "Nothing to stash")
      checkout(false)
      return
    end

    update("inspect", "success", "Local changes found")
    update("stash", "active")
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
          local stash_error = command_error(stash_result)
          update("stash", "error", stash_error)
          finish("error", "Could not stash working changes", stash_error)
          return
        end
        update("stash", "success", "stash@{0}")
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
            vim.schedule(function()
              local progress = require("github_pr_progress").new(item)
              M._checkout(root, item, deps, progress)
            end)
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
