-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

local uname = vim.uv.os_uname()
print(uname.sysname)

-- macos用の設定
if uname.sysname == "Darwin" then
  -- Resize window using <ctrl> arrow keys
  map("n", "<M-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
  map("n", "<M-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
  map("n", "<M-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
  map("n", "<M-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
end

-- ============================================================
-- DAP 追加キーマップ  <leader>d*
-- (rust.lua に定義済みの db/dB/dr/dl/dh/ds/du は除く)
-- ============================================================
map("n", "<leader>dc", function() require("dap").continue() end,
  { desc = "Continue / Start Debug" })
map("n", "<leader>dC", function() require("dap").run_to_cursor() end,
  { desc = "Run to Cursor" })
map("n", "<leader>di", function() require("dap").step_into() end,
  { desc = "Step Into" })
map("n", "<leader>do", function() require("dap").step_out() end,
  { desc = "Step Out" })
map("n", "<leader>dO", function() require("dap").step_over() end,
  { desc = "Step Over" })
map("n", "<leader>dp", function() require("dap").pause() end,
  { desc = "Pause" })
map("n", "<leader>dt", function() require("dap").terminate() end,
  { desc = "Terminate Debug Session" })
map("n", "<leader>de", function() require("dapui").eval() end,
  { desc = "Eval (DAP UI)" })
map("v", "<leader>de", function() require("dapui").eval() end,
  { desc = "Eval Selection (DAP UI)" })

-- ============================================================
-- Neotest (テスト) キーマップ  <leader>t*
-- ============================================================
map("n", "<leader>tt", function() require("neotest").run.run() end,
  { desc = "Run Nearest Test" })
map("n", "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end,
  { desc = "Run All Tests in File" })
map("n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,
  { desc = "Debug Nearest Test (DAP)" })
map("n", "<leader>tl", function() require("neotest").run.run_last() end,
  { desc = "Re-run Last Test" })
map("n", "<leader>tS", function() require("neotest").run.stop() end,
  { desc = "Stop Running Tests" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end,
  { desc = "Toggle Test Summary Panel" })
map("n", "<leader>to", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Show Test Output" })
map("n", "<leader>tO", function() require("neotest").output_panel.toggle() end,
  { desc = "Toggle Test Output Panel" })
map("n", "]t", function() require("neotest").jump.next({ status = "failed" }) end,
  { desc = "Next Failed Test" })
map("n", "[t", function() require("neotest").jump.prev({ status = "failed" }) end,
  { desc = "Prev Failed Test" })

-- ============================================================
-- Database / dadbod キーマップ  <leader>D*
-- ============================================================
map("n", "<leader>Du", "<cmd>DBUIToggle<cr>",
  { desc = "Toggle DB UI (dadbod)" })
map("n", "<leader>Df", "<cmd>DBUIFindBuffer<cr>",
  { desc = "Find DB Buffer" })
map("n", "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>",
  { desc = "Rename DB Buffer" })
map("n", "<leader>Dq", "<cmd>DBUILastQueryInfo<cr>",
  { desc = "Last Query Info" })

-- ============================================================
-- マウス設定
-- ============================================================
-- <C-LeftMouse> のデフォルトタグジャンプ(定義ダイアログ)を無効化して通常クリックに戻す
map("n", "<C-LeftMouse>", "<LeftMouse>", { desc = "Left click (no tag jump)" })
-- 右クリックでタグジャンプ(定義ダイアログ)を起動
map("n", "<RightMouse>", "<LeftMouse><C-]>", { desc = "Go to Definition (right click)" })
