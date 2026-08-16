package.path = "./lua/?.lua;" .. package.path

local octo_review = require("octo_review")

local function fail(message)
  error(message, 2)
end

local function equal(actual, expected, message)
  if actual ~= expected then
    fail((message or "values differ") .. ("\nexpected: %s\nactual:   %s"):format(tostring(expected), tostring(actual)))
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

local function mapping(opts, group, action)
  local value = opts.mappings[group] and opts.mappings[group][action]
  if not value then
    fail(("missing mapping %s.%s"):format(group, action))
  end
  return value.lhs
end

test("uses the native Snacks picker and gruvbox palette", function()
  local opts = octo_review.opts()
  equal(opts.picker, "snacks")
  equal(opts.colors.white, "#ebdbb2")
  equal(opts.colors.black, "#282828")
  equal(opts.colors.dark_green, "#98971a")
  equal(opts.colors.dark_red, "#cc241d")
end)

test("uses a logical leader-only review workflow", function()
  local opts = octo_review.opts()
  equal(opts.mappings_disable_default, true)
  equal(mapping(opts, "pull_request", "review_start"), "<leader>ps")
  equal(mapping(opts, "pull_request", "review_resume"), "<leader>pr")
  equal(mapping(opts, "review_diff", "add_review_comment"), "<leader>pc")
  equal(mapping(opts, "review_diff", "add_review_suggestion"), "<leader>ps")
  equal(mapping(opts, "review_diff", "submit_review"), "<leader>pS")
  equal(mapping(opts, "submit_win", "approve_review"), "<leader>pa")
  equal(mapping(opts, "submit_win", "comment_review"), "<leader>pc")
  equal(mapping(opts, "submit_win", "request_changes"), "<leader>pr")
  equal(opts.picker_config.mappings.checkout_pr.lhs, "<leader>po")
  equal(opts.picker_config.mappings.merge_pr.lhs, "<leader>pM")

  for group, actions in pairs(opts.mappings) do
    for action, value in pairs(actions) do
      if value.lhs:find("<localleader>", 1, true) or value.lhs:find("<C-m>", 1, true) then
        fail(("%s.%s uses a forbidden mapping: %s"):format(group, action, value.lhs))
      end
    end
  end
  for action, value in pairs(opts.picker_config.mappings) do
    if not value.lhs:find("<leader>", 1, true) then
      fail(("picker %s is not leader-based: %s"):format(action, value.lhs))
    end
  end
end)

test("passes uppercase shell proxies to Octo's lowercase-only gh environment", function()
  local env = octo_review.proxy_env({
    HTTP_PROXY = "http://proxy:8000",
    HTTPS_PROXY = "http://proxy:8443",
  })
  equal(env.http_proxy, "http://proxy:8000")
  equal(env.https_proxy, "http://proxy:8443")
end)

test("registers pull-request leader entry points", function()
  local keys = octo_review.keys()
  local found = {}
  for _, key in ipairs(keys) do
    found[key[1]] = key.desc
  end
  equal(found["<leader>pp"], "Pull requests")
  equal(found["<leader>pn"], "GitHub notifications")
  equal(found["<leader>pa"], "Octo actions")
end)

io.stdout:write("all Octo configuration tests passed\n")
