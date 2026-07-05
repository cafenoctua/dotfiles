return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_colors = function(colors)
        colors.bg = "#0d1b3e"
        colors.bg_dark = "#0a1530"
        colors.bg_float = "#0d1b3e"
        colors.bg_popup = "#0d1b3e"
        colors.bg_sidebar = "#0a1530"
        colors.bg_statusline = "#0a1530"
      end,
      -- rust-analyzer は main から到達しないコードに "unnecessary" タグを
      -- 付与し、tokyonight はこれを薄いグレー表示にする。未使用でも通常の
      -- シンタックスハイライトのまま読めるように上書きする。
      on_highlights = function(hl, colors)
        local unnecessary = { fg = colors.none, bg = colors.none, sp = colors.none, undercurl = false }
        hl.DiagnosticUnnecessary = unnecessary
        hl["@lsp.mod.unnecessary"] = unnecessary
        hl["@lsp.typemod.function.unnecessary"] = unnecessary
        hl["@lsp.typemod.method.unnecessary"] = unnecessary
        hl["@lsp.typemod.variable.unnecessary"] = unnecessary
      end,
    },
  },
}
