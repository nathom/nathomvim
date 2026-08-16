local M = {}

local Progress = {}
Progress.__index = Progress

local stages = {
  { key = "save", label = "Save modified buffers" },
  { key = "inspect", label = "Inspect working tree" },
  { key = "stash", label = "Stash local changes" },
  { key = "checkout", label = "Checkout PR branch" },
  { key = "detached", label = "Checkout detached", optional = true },
  { key = "reload", label = "Reload editor buffers" },
  { key = "restore", label = "Restore local changes", optional = true },
}

local status_style = {
  pending = { icon = "○", hl = "Comment" },
  active = { icon = "●", hl = "DiagnosticInfo" },
  success = { icon = "✓", hl = "DiagnosticOk" },
  skipped = { icon = "–", hl = "Comment" },
  warning = { icon = "!", hl = "DiagnosticWarn" },
  error = { icon = "✗", hl = "DiagnosticError" },
}

local function clean(value)
  return tostring(value or ""):gsub("%s+", " ")
end

local function fit(value, width)
  value = clean(value)
  if vim.fn.strdisplaywidth(value) <= width then
    return value
  end
  return vim.fn.strcharpart(value, 0, width - 1) .. "…"
end

function Progress:render()
  if self.closed or not self.win:buf_valid() then
    return
  end

  local lines = {
    fit(("#%d  %s"):format(self.pr.number, self.pr.title or "Pull request"), 76),
    fit(self.pr.branch and ("Branch: " .. self.pr.branch) or "", 76),
    "",
  }
  local highlights = {
    { line = 0, hl = "Title" },
    { line = 1, hl = "Comment" },
  }

  for _, definition in ipairs(stages) do
    local step = self.steps[definition.key]
    if not definition.optional or step.status ~= "pending" then
      local style = status_style[step.status]
      local detail = step.detail ~= "" and ("  " .. fit(step.detail, 46)) or ""
      lines[#lines + 1] = ("%s  %-23s%s"):format(style.icon, definition.label, detail)
      highlights[#highlights + 1] = { line = #lines - 1, hl = style.hl }
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = fit(self.message, 76)
  highlights[#highlights + 1] = {
    line = #lines - 1,
    hl = self.finished and (self.finish_status == "success" and "DiagnosticOk" or "DiagnosticError") or "Comment",
  }
  if self.detail ~= "" then
    lines[#lines + 1] = fit(self.detail, 76)
    highlights[#highlights + 1] = { line = #lines - 1, hl = "Comment" }
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = self.finished and "Press <Enter>, <Esc>, or q to close"
    or "Checkout in progress…  q hides this window"

  vim.bo[self.win.buf].modifiable = true
  vim.api.nvim_buf_set_lines(self.win.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(self.win.buf, self.namespace, 0, -1)
  for _, highlight in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(self.win.buf, self.namespace, highlight.hl, highlight.line, 0, -1)
  end
  vim.bo[self.win.buf].modifiable = false
end

function Progress:update(stage, status, detail)
  local step = assert(self.steps[stage], "unknown checkout stage: " .. stage)
  step.status = status
  step.detail = clean(detail)
  self:render()
end

function Progress:finish(status, message, detail)
  self.finished = true
  self.finish_status = status
  self.message = clean(message)
  self.detail = clean(detail)
  if not self.closed and self.win:win_valid() then
    self.win:set_title((" PR #%d · %s "):format(self.pr.number, status == "success" and "Done" or "Failed"))
  end
  self:render()
end

function M.new(pr)
  local self = setmetatable({
    pr = pr,
    steps = {},
    message = "Preparing checkout…",
    detail = "",
    namespace = vim.api.nvim_create_namespace("github-pr-checkout"),
  }, Progress)
  for _, definition in ipairs(stages) do
    self.steps[definition.key] = { status = "pending", detail = "" }
  end

  self.win = Snacks.win({
    title = (" Checkout PR #%d "):format(pr.number),
    title_pos = "center",
    footer = " q close ",
    footer_pos = "center",
    width = 82,
    height = 15,
    border = "rounded",
    backdrop = 40,
    enter = true,
    text = { "Preparing checkout…" },
    bo = { bufhidden = "wipe", buftype = "nofile" },
    wo = { cursorline = false, wrap = false },
    keys = {
      ["<esc>"] = "close",
      ["<cr>"] = function(win)
        if self.finished then
          win:close()
        end
      end,
      q = "close",
    },
    on_close = function()
      self.closed = true
    end,
  })
  self:render()
  return self
end

return M
