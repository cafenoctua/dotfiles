return {
  "folke/snacks.nvim",
  opts = {
    -- dashboardを無効化してexplorerが閉じられないようにする
    dashboard = { enabled = false },
    -- 起動時にexplorerを自動表示
    explorer = {
      replace_netrw = true,
    },
  },
}
