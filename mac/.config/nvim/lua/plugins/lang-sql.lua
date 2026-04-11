-- dbtファイルタイプ検出 (LSPアタッチ前に実行)
vim.filetype.add({
  extension = {
    sql = "sql",
  },
  pattern = {
    [".*dbt_project%.yml"] = "yaml",
    [".*profiles%.yml"] = "yaml",
  },
})

return {
  -- sqls: SQL言語サーバー
  -- フォーマット機能は無効化してsqlfluffに委譲
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sqls = {
          -- DB接続設定は ~/.config/sqls/config.yml で管理 (nvim設定に含めない)
          settings = {
            sqls = {
              connections = {},
            },
          },
          on_attach = function(client, _)
            -- sqls自身のフォーマットは使わない (sqlfluffを使う)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },

  -- sqlfluff: SQLフォーマッター + リンター
  -- プロジェクトルートの .sqlfluff で dialect を上書き可能
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sqlfluff" },
      },
      formatters = {
        sqlfluff = {
          args = { "format", "--dialect", "ansi", "-" },
          stdin = true,
        },
      },
    },
  },

  -- treesitter: sqlパーサー
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "sql",
      })
    end,
  },

  -- Mason: sqls / sqlfluff を自動インストール
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "sqls",
        "sqlfluff",
      },
    },
  },

  -- vim-dadbod: データベース接続のコアライブラリ
  {
    "tpope/vim-dadbod",
    lazy = true,
  },

  -- vim-dadbod-ui: データベースブラウザ + クエリ実行UI
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      -- クエリ保存ディレクトリ
      vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")
      -- 保存時の自動実行は無効 (手動実行を基本とする)
      vim.g.db_ui_execute_on_save = 0
      -- テーブルヘルパー (BigQuery対応)
      vim.g.db_ui_table_helpers = {
        postgresql = {
          Count = "select count(1) from {optional_schema}{table}",
          Explain = "EXPLAIN ANALYZE {last_query}",
        },
        bigquery = {
          Count = "SELECT COUNT(1) FROM `{table}`",
        },
      }
    end,
  },

  -- vim-dadbod-completion: SQLバッファでのDB補完 (cmpソース)
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })
    end,
  },
}
