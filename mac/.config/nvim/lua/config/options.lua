-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- SQL デフォルト方言ヒント
vim.g.sql_type_default = "sql"

-- 幅広CSV/JSONファイルでの構文ハイライト速度低下防止
vim.opt.synmaxcol = 200

-- dbtモデルのdiff表示を改善 (スマートなアライメント)
vim.opt.diffopt:append("linematch:60")

-- DAP ブレークポイントサイン定義
vim.fn.sign_define("DapBreakpoint", {
  text = "",
  texthl = "DapBreakpoint",
  linehl = "DapBreakpointLine",
  numhl = "DapBreakpointNum",
})
vim.fn.sign_define("DapBreakpointCondition", {
  text = "",
  texthl = "DapBreakpointCondition",
  linehl = "",
  numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
  text = "",
  texthl = "DapLogPoint",
  linehl = "",
  numhl = "",
})
vim.fn.sign_define("DapStopped", {
  text = "",
  texthl = "DapStopped",
  linehl = "DapStoppedLine",
  numhl = "",
})

-- filetype別インデント設定
-- Python/Rust: 4スペース (PEP8 / Rust標準)
-- SQL: 2スペース
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "rust" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- LSPログの肥大化防止: 起動時に1日以上古いlsp.logを削除
local lsp_log = vim.fn.stdpath("state") .. "/lsp.log"
local stat = vim.uv.fs_stat(lsp_log)
if stat and (os.time() - stat.mtime.sec) > 86400 then
  os.remove(lsp_log)
end

-- 診断メッセージをカーソル停止時にフロートウィンドウで折り返し表示
vim.diagnostic.config({
  float = {
    border = "rounded",
    source = true,   -- どのLSPからの警告か表示
    wrap = true,     -- 長いメッセージを折り返す
    max_width = 80,  -- フロートの最大幅
  },
  virtual_text = {
    spacing = 4,
    prefix = "●",
    -- 長い警告は短縮して行末に表示（全文はフロートで確認）
    format = function(diagnostic)
      local msg = diagnostic.message
      if #msg > 50 then
        return msg:sub(1, 50) .. "..."
      end
      return msg
    end,
  },
})
