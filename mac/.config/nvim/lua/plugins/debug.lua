return {
  -- nvim-dap-ui: IDE-likeなデバッグパネルレイアウト設定
  -- rust.lua の DAP UI 設定を上書きして統一レイアウトを適用
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      layouts = {
        {
          -- 左パネル: scopes / breakpoints / stacks / watches
          elements = {
            { id = "scopes",      size = 0.40 },
            { id = "breakpoints", size = 0.20 },
            { id = "stacks",      size = 0.20 },
            { id = "watches",     size = 0.20 },
          },
          size = 45,
          position = "left",
        },
        {
          -- 下パネル: REPL / console
          elements = {
            { id = "repl",    size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 12,
          position = "bottom",
        },
      },
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.9,
        border = "rounded",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      render = {
        max_type_length = nil,
        max_value_lines = 100,
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      -- デバッグ開始時に自動open、終了時に自動close
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- nvim-dap-virtual-text: デバッグ中に変数値をインライン表示
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == "inline" then
          return " = " .. variable.value
        else
          return variable.name .. " = " .. variable.value
        end
      end,
      -- nvim 0.10+ ではインライン表示、それ以外はeol
      virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
    },
  },
}
