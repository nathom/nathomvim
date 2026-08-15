package.path = "./lua/?.lua;" .. package.path

local github_pr = require("github_pr")

local function fail(message)
  error(message, 2)
end

local function equal(actual, expected, message)
  if actual ~= expected then
    fail((message or "values differ") .. ("\nexpected: %s\nactual:   %s"):format(tostring(expected), tostring(actual)))
  end
end

local function contains(haystack, needle, message)
  if not haystack:find(needle, 1, true) then
    fail((message or "substring not found") .. ("\nneedle: %s\nhaystack: %s"):format(needle, haystack))
  end
end

local function command(args)
  return table.concat(args, " ")
end

local function fake_runner(expected, calls)
  local index = 0
  return function(args, cwd, callback)
    index = index + 1
    local step = expected[index]
    if not step then
      fail("unexpected command: " .. command(args))
    end
    equal(command(args), step.command, "command mismatch")
    equal(cwd, "/repo", "command cwd mismatch")
    calls[#calls + 1] = step.command
    callback(step.result)
  end
end

local function test(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if not ok then
    io.stderr:write("not ok - " .. name .. "\n" .. err .. "\n")
    os.exit(1)
  end
  io.stdout:write("ok - " .. name .. "\n")
end

test("flattens paginated PRs into fuzzy-searchable Snacks items", function()
  local items = github_pr._items({
    {
      {
        number = 42,
        title = "Fix checkout race",
        user = { login = "octocat" },
        head = { ref = "fix/checkout-race" },
      },
    },
    {
      {
        number = 7,
        title = "Add retries",
        user = { login = "hubot" },
        head = { ref = "retries" },
      },
    },
  })

  equal(#items, 2)
  equal(items[1].number, 42)
  equal(items[1].text, "#42  Fix checkout race  @octocat  fix/checkout-race")
  equal(items[2].number, 7)
  contains(items[2].text, "Add retries")
  contains(items[2].text, "@hubot")
  contains(items[2].text, "retries")
end)

test("lists every open PR through the paginated gh API", function()
  local calls = {}
  local listed
  local run = fake_runner({
    {
      command = "gh api --method GET --paginate --slurp repos/{owner}/{repo}/pulls?state=open&per_page=100",
      result = { code = 0, stdout = "api-json", stderr = "" },
    },
  }, calls)

  github_pr._list("/repo", {
    run = run,
    decode = function(value)
      equal(value, "api-json")
      return {
        {
          {
            number = 99,
            title = "From the API",
            user = { login = "octocat" },
            head = { ref = "api-branch" },
          },
        },
      }
    end,
    notify = function(message)
      fail("unexpected notification: " .. message)
    end,
  }, function(items)
    listed = items
  end)

  equal(#calls, 1)
  equal(#listed, 1)
  equal(listed[1].number, 99)
end)

test("writes buffers, autostashes dirty state, then checks out the selected PR", function()
  local calls = {}
  local notifications = {}
  local checked_time = false
  local wrote_all = false
  local run = fake_runner({
    {
      command = "git status --porcelain=v1 --untracked-files=all",
      result = { code = 0, stdout = " M lua/plugins/git.lua\n?? notes.txt\n", stderr = "" },
    },
    {
      command = "git stash push --include-untracked -m nvim: before checkout of PR #42",
      result = { code = 0, stdout = "Saved working directory and index state\n", stderr = "" },
    },
    {
      command = "gh pr checkout 42",
      result = { code = 0, stdout = "Switched to branch 'fix/checkout-race'\n", stderr = "" },
    },
  }, calls)

  github_pr._checkout("/repo", { number = 42 }, {
    run = run,
    write_all = function()
      wrote_all = true
      return true
    end,
    checktime = function()
      checked_time = true
    end,
    notify = function(message, level)
      notifications[#notifications + 1] = { message = message, level = level }
    end,
  })

  equal(wrote_all, true)
  equal(#calls, 3)
  equal(checked_time, true)
  equal(#notifications, 1)
  contains(notifications[1].message, "PR #42")
  contains(notifications[1].message, "stashed")
end)

test("restores the autostash when gh checkout fails", function()
  local calls = {}
  local notifications = {}
  local run = fake_runner({
    {
      command = "git status --porcelain=v1 --untracked-files=all",
      result = { code = 0, stdout = " M init.lua\n", stderr = "" },
    },
    {
      command = "git stash push --include-untracked -m nvim: before checkout of PR #7",
      result = { code = 0, stdout = "Saved working directory and index state\n", stderr = "" },
    },
    {
      command = "gh pr checkout 7",
      result = { code = 1, stdout = "", stderr = "branch is already checked out\n" },
    },
    {
      command = "git stash pop --index stash@{0}",
      result = { code = 0, stdout = "On branch main\n", stderr = "" },
    },
  }, calls)

  github_pr._checkout("/repo", { number = 7 }, {
    run = run,
    write_all = function()
      return true
    end,
    checktime = function()
      fail("checktime should not run after a failed checkout")
    end,
    notify = function(message, level)
      notifications[#notifications + 1] = { message = message, level = level }
    end,
  })

  equal(#calls, 4)
  equal(#notifications, 1)
  contains(notifications[1].message, "branch is already checked out")
  contains(notifications[1].message, "restored")
end)

test("skips stashing for a clean worktree", function()
  local calls = {}
  local run = fake_runner({
    {
      command = "git status --porcelain=v1 --untracked-files=all",
      result = { code = 0, stdout = "", stderr = "" },
    },
    {
      command = "gh pr checkout 7",
      result = { code = 0, stdout = "Switched to branch 'retries'\n", stderr = "" },
    },
  }, calls)

  github_pr._checkout("/repo", { number = 7 }, {
    run = run,
    write_all = function()
      return true
    end,
    checktime = function() end,
    notify = function() end,
  })

  equal(#calls, 2)
end)

io.stdout:write("all github_pr tests passed\n")
