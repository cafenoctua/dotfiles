-- Claude Code のバックグラウンドセッション（agent view）が作った変更をレビューするための設定
-- worktree は既定で <repo>/.claude/worktrees/<name>/ に作られ、ブランチは worktree-<name>

-- origin のデフォルトブランチ（例: origin/main）。取れなければ origin/main
local function base_ref()
  local ref = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })[1]
  if vim.v.shell_error ~= 0 or not ref or ref == "" then
    return "origin/main"
  end
  return ref
end

-- `git worktree list --porcelain` から { path, branch } の一覧を作る（メインのチェックアウトは除く）
local function list_worktrees()
  local lines = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local items, cur, first = {}, nil, true
  for _, line in ipairs(lines) do
    local path = line:match("^worktree (.+)$")
    if path then
      cur = { path = path }
    elseif cur then
      local branch = line:match("^branch refs/heads/(.+)$")
      if branch then
        cur.branch = branch
      elseif line == "" then
        if not first and cur.branch then
          table.insert(items, cur)
        end
        first, cur = false, nil
      end
    end
  end
  if cur and not first and cur.branch then
    table.insert(items, cur)
  end
  return items
end

local function review_worktree()
  local items = list_worktrees()
  if #items == 0 then
    vim.notify("レビューできる worktree がありません", vim.log.levels.INFO)
    return
  end
  vim.ui.select(items, {
    prompt = "Review worktree",
    format_item = function(item)
      return item.branch .. "  (" .. vim.fn.fnamemodify(item.path, ":~:.") .. ")"
    end,
  }, function(choice)
    if choice then
      vim.cmd("DiffviewOpen " .. base_ref() .. "..." .. choice.branch)
    end
  end)
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gv",
        function()
          vim.cmd("DiffviewOpen " .. base_ref() .. "...HEAD")
        end,
        desc = "Diffview: current branch vs base",
      },
      { "<leader>gV", review_worktree, desc = "Diffview: review a worktree branch" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    },
    opts = {},
  },
}
