return {
  "mfussenegger/nvim-dap",
  -- Only enabled if lang-python or lang-go (languages with debug support)
  enabled = require("nixCatsUtils").enableForCategory("lang-python", false)
    or require("nixCatsUtils").enableForCategory("lang-go", false),
  ft = { "python", "go" },
  dependencies = {
    "rcarriga/nvim-dap-ui",

    -- Required dependency for nvim-dap-ui
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    local function get_venv_python()
      local cwd = vim.fn.getcwd()
      local candidates = {
        cwd .. "/.venv/bin/python",
        cwd .. "/.venv/Scripts/python.exe",
      }

      for _, path in ipairs(candidates) do
        if vim.loop.fs_stat(path) then
          return path
        end
      end
    end

    local function get_python_path()
      local venv_python = get_venv_python()
      if venv_python then
        return venv_python
      end

      local python3 = vim.fn.exepath("python3")
      if python3 ~= "" then
        return python3
      end

      local python = vim.fn.exepath("python")
      if python ~= "" then
        return python
      end

      return "python"
    end

    require("nvim-dap-virtual-text").setup({})

    vim.keymap.set("n", "<F6>", dap.continue, { desc = "Debug: Start/Continue" })
    vim.keymap.set("n", "<F7>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F8>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F9>", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<F10>", dap.run_to_cursor, { desc = "Debug: Run to Cursor" })
    vim.keymap.set("n", "<F11>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<F12>", function()
      dapui.toggle()
    end, { desc = "Debug: Toggle UI" })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Breakpoint" })
    vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: Terminate" })
    vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "Debug: Pause" })
    vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "Debug: Restart" })
    vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })

    dap.listeners.after.event_initialized["python_exception_breakpoints"] = function(session)
      if session.config.type == "python" then
        dap.set_exception_breakpoints({ "uncaught" })
      end
    end

    local checked_debugpy = {}
    local function ensure_debugpy(python)
      if checked_debugpy[python] then
        return
      end
      vim.fn.system({ python, "-c", "import debugpy" })
      if vim.v.shell_error ~= 0 then
        error(
          ("debugpy is not installed in the virtualenv (%s).\nInstall it with `%s -m pip install debugpy`."):format(
            python,
            python
          ),
          0
        )
      end
      checked_debugpy[python] = true
    end

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    dap.adapters.python = function(cb)
      local venv_python = get_venv_python()
      if venv_python then
        ensure_debugpy(venv_python)
        cb({
          type = "executable",
          command = venv_python,
          args = { "-m", "debugpy.adapter" },
        })
        return
      end

      if vim.fn.executable("uv") == 1 then
        cb({
          type = "executable",
          command = "uv",
          args = { "run", "--with", "debugpy", "debugpy-adapter" },
        })
        return
      end

      cb({
        type = "executable",
        command = get_python_path(),
        args = { "-m", "debugpy.adapter" },
      })
    end

    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = get_python_path,
      },
      {
        type = "python",
        request = "attach",
        name = "Attach to Debugpy",
        connect = {
          host = "127.0.0.1",
          port = 5678,
        },
      },
    }
  end,
}
