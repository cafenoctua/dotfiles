return {
  -- neotest: Python + Rust アダプター登録
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}

      -- Python: pytest runner + DAP統合 + mise python検出
      table.insert(
        opts.adapters,
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
          args = { "--log-level=DEBUG", "-v", "--tb=short" },
          python = function()
            -- 仮想環境を優先、次にmise管理のpython
            local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_DEFAULT_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            local mise_python = vim.fn.trim(vim.fn.system("mise which python 2>/dev/null"))
            if mise_python ~= "" and vim.fn.filereadable(mise_python) == 1 then
              return mise_python
            end
            return "python3"
          end,
        })
      )

      -- Rust: neotest-rust + codelldb DAP統合
      table.insert(
        opts.adapters,
        require("neotest-rust")({
          args = { "--no-capture" },
          dap_adapter = "codelldb",
        })
      )

      -- 出力設定: 失敗時のみ自動展開
      opts.output = {
        enabled = true,
        open_on_run = "short",
      }

      opts.summary = {
        enabled = true,
        animated = true,
        follow = true,
        expand_errors = true,
      }

      opts.status = {
        enabled = true,
        signs = true,   -- gutterにpass/failサインを表示
        virtual_text = false,
      }

      opts.quickfix = {
        enabled = true,
        open = false,   -- quickfixは自動展開しない（summaryを使う）
      }

      return opts
    end,
  },
}
