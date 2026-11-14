-- Rust本体のLSP/DAP/テスト統合は lazyvim.plugins.extras.lang.rust (rustaceanvim) に委譲。
-- ここでは extra がカバーしない Mason ツールの補完のみを行う。
return {
  -- Mason: rust-analyzer / rustfmt はextraが担保しないため明示的にインストール
  -- (codelldb は lang.rust extra 側の mason.nvim ブロックが担保する)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "rust-analyzer",
        "rustfmt",
      })
    end,
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
}
