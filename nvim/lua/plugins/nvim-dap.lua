return {
  -- ========== Core DAP ==========
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI للـ debugger
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      -- Virtual text بيعرض قيم المتغيرات جنب الكود
      "theHamsta/nvim-dap-virtual-text",
      -- Mason bridge للـ debuggers
      "jay-babu/mason-nvim-dap.nvim",
      -- Language-specific
      "mfussenegger/nvim-dap-python",  -- Python
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- ========== Mason DAP (C وRust) ==========
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "codelldb",  -- C و Rust
        },
        -- مهم جداً: مش optional زي ما يبدو
        handlers = {},
      })

      -- ========== Python ==========
      require("dap-python").setup(
        vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
      )

      -- ========== Virtual Text ==========
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        commented = false,
      })

      -- ========== UI ==========
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.35 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.20 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- فتح/إغلاق UI تلقائياً مع الـ session
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ========== Keybindings ==========
      local opts = { silent = true }

      -- Breakpoints
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end, vim.tbl_extend("force", opts, { desc = "Conditional breakpoint" }))

      -- Control
      vim.keymap.set("n", "<leader>dc", dap.continue,        vim.tbl_extend("force", opts, { desc = "Continue / Start" }))
      vim.keymap.set("n", "<leader>dn", dap.step_over,       vim.tbl_extend("force", opts, { desc = "Step over" }))
      vim.keymap.set("n", "<leader>di", dap.step_into,       vim.tbl_extend("force", opts, { desc = "Step into" }))
      vim.keymap.set("n", "<leader>do", dap.step_out,        vim.tbl_extend("force", opts, { desc = "Step out" }))
      vim.keymap.set("n", "<leader>dT", dap.terminate,       vim.tbl_extend("force", opts, { desc = "Terminate" }))
      vim.keymap.set("n", "<leader>dr", dap.run_to_cursor,   vim.tbl_extend("force", opts, { desc = "Run to cursor" }))

      -- UI
      vim.keymap.set("n", "<leader>du", dapui.toggle,        vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))

    end,
  },
}
