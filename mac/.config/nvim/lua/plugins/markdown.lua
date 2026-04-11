return {
  -- yaml frontmatter のレンダリングサポート用
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "yaml" })
    end,
  },

  -- ブラウザプレビュー: <leader>mp + mermaid ダークテーマ設定
  -- LazyVim extra が <leader>cp を管理するため、init で g: vars を設定
  -- build: yarn の代わりに npm install を使用（yarn が未インストールの環境向け）
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview Toggle (browser)",
        ft = "markdown",
      },
    },
    init = function()
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = { theme = "dark" }, -- mermaid.js にダークテーマを渡す
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_auto_close = 1
    end,
  },

  -- テーブル整形: <leader>tm
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" },
    },
  },

  -- render-markdown.nvim: code block に thin border を追加
  -- mermaid フェンスの境界を視覚的に明確化
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = { sign = false, width = "block", right_pad = 1, border = "thin" },
      heading = { sign = false, icons = {} },
      checkbox = { enabled = false },
    },
  },

  -- フォーマット専用キーマップ <leader>mf
  -- formatters_by_ft は LazyVim extra に任せる（markdownlint-cli2 + prettier）
  {
    "stevearc/conform.nvim",
    optional = true,
    keys = {
      {
        "<leader>mf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        ft = "markdown",
        desc = "Format Markdown",
      },
    },
  },
}
