return {
  -- Rustのサポートを追加
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "toml",
      })
    end,
  },

  -- rust-analyzer (LSP) の設定
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- 型ヒントの表示
              checkOnSave = {
                command = "clippy",
              },
              procMacro = {
                enable = true,
              },
              -- インレイヒント（型情報の自動表示）
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "never",
                },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "never",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        },
      },
    },
  },

  -- Mason（ツール自動インストーラー）にRustツールを追加
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer", -- LSPサーバー
        "rustfmt",       -- フォーマッター
        "codelldb",      -- デバッガー
      },
    },
  },

  -- mason-lspconfigでLSPサーバーを自動セットアップ
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "rust_analyzer",
      },
    },
  },

  -- Rustのフォーマット設定
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },

  -- DAP (Debug Adapter Protocol) の設定 - Rustデバッグ用
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      -- DAP UI（デバッグ画面のレイアウト）
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
    },
    config = function()
      local dap = require("dap")

      -- codelldb のパス（Mason がインストールする場所）
      local codelldb_path = vim.fn.exepath("codelldb")
        or (vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb")

      -- Rust 用アダプター設定
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      -- Rust の起動設定
      dap.configurations.rust = {
        {
          name = "Launch binary",
          type = "codelldb",
          request = "launch",
          -- cargo build 後のバイナリを自動検出
          program = function()
            -- プロジェクト名を Cargo.toml から読み取る
            local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
            local bin_name = vim.fn.fnamemodify(
              vim.fn.fnamemodify(cargo_toml, ":h"),
              ":t"
            )
            local default_bin = vim.fn.getcwd() .. "/target/debug/" .. bin_name
            return vim.fn.input("Binary path: ", default_bin, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Debug test",
          type = "codelldb",
          request = "launch",
          -- cargo test --no-run でビルドされたテストバイナリを取得
          program = function()
            local crate = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            local pattern = vim.fn.getcwd() .. "/target/debug/deps/" .. crate .. "-*"
            -- 最新のテストバイナリを取得（拡張子なし = 実行可能ファイル）
            local bins = vim.fn.glob(pattern, false, true)
            bins = vim.tbl_filter(function(f)
              return not f:match("%.[^/]+$")  -- 拡張子なしのみ（.d ファイル除外）
            end, bins)
            if #bins == 0 then
              vim.notify("テストバイナリが見つかりません。先に `cargo test --no-run` を実行してください", vim.log.levels.ERROR)
              return nil
            end
            -- 更新日時が最新のものを選択
            table.sort(bins, function(a, b)
              return vim.fn.getftime(a) > vim.fn.getftime(b)
            end)
            return vim.fn.input("Test binary: ", bins[1], "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          -- テスト名を指定（空欄で全テスト実行）
          args = function()
            local test_name = vim.fn.input("Test name (空欄で全テスト): ")
            local base_args = { "--test-threads=1" }
            if test_name ~= "" then
              table.insert(base_args, 1, test_name)
            end
            return base_args
          end,
        },
      }

      -- キーマップ
      local map = vim.keymap.set
      map("n", "<F5>",  dap.continue,          { desc = "DAP: Continue" })
      map("n", "<F10>", dap.step_over,          { desc = "DAP: Step Over" })
      map("n", "<F11>", dap.step_into,          { desc = "DAP: Step Into" })
      map("n", "<F12>", dap.step_out,           { desc = "DAP: Step Out" })
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP: Conditional Breakpoint" })
      map("n", "<leader>dr", dap.repl.open,     { desc = "DAP: Open REPL" })
      map("n", "<leader>dl", dap.run_last,       { desc = "DAP: Run Last" })
      -- カーソル下の変数をホバー表示（デバッグ中のみ有効）
      -- 同じキーで開閉トグル
      local hover_win = nil
      local function toggle_hover()
        if hover_win and vim.api.nvim_win_is_valid(hover_win) then
          vim.api.nvim_win_close(hover_win, true)
          hover_win = nil
        else
          local widget = require("dap.ui.widgets").hover()
          hover_win = widget.win
        end
      end
      map("n", "<leader>dh", toggle_hover, { desc = "DAP: Toggle Hover Variable" })
      -- 選択範囲の式を評価
      map("v", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "DAP: Hover Expression" })
      -- スコープ内の全変数をフローティングウィンドウで表示
      map("n", "<leader>ds", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end, { desc = "DAP: Show Scopes" })

      -- DAP UI の自動開閉
      local dapui_ok, dapui = pcall(require, "dapui")
      if dapui_ok then
        dapui.setup()
        map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"]     = dapui.close
      end
    end,
  },

  -- crates.io の依存関係管理プラグイン（Cargo.tomlでクレート情報を表示）
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      src = {
        cmp = { enabled = true },
      },
    },
  },

  -- nvim-cmpにcrates.nvimを追加
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "saecki/crates.nvim" },
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "crates" })
    end,
  },
}
