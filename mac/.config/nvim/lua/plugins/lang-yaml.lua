-- dbt_project.yml / profiles.yml の filetype 検出は lang-sql.lua に定義済み
-- このファイルではそれを重複させない

-- YAML バッファの 2-space インデント設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yaml.docker-compose" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
  desc = "YAML: 2-space indentation",
})

return {
  -- yamlls 設定: LazyVim extra の SchemaStore 設定を拡張
  -- dbt_project.yml / schema.yml のスキーマは SchemaStore が自動検出する
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              hover = true,
              completion = true,
              validate = true,
              format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true,
                proseWrap = "preserve",
                printWidth = 120, -- dbt schema.yml は長い行になりがち
              },
            },
          },
        },
      },
    },
  },

  -- YAML フォーマッター: prettier
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        yaml = { "prettier" },
      },
    },
  },
}
