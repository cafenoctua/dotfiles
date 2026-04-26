return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Grep Word Under Cursor" },
      -- 拡張子・ファイル名フィルター付きlive_grep
      {
        "<leader>fG",
        function()
          local ext = vim.fn.input("ファイル拡張子 (例: lua,py): ")
          local args = { "--hidden", "--glob", "!**/.git/*" }
          for e in ext:gmatch("[^,]+") do
            e = e:match("^%s*(.-)%s*$")
            if e ~= "" then
              local glob
              if e:sub(1, 1) == "*" then
                glob = e
              elseif e:sub(1, 1) == "." then
                glob = "*" .. e
              else
                glob = "*." .. e
              end
              table.insert(args, "--glob")
              table.insert(args, glob)
            end
          end
          require("telescope.builtin").live_grep({
            additional_args = args,
          })
        end,
        desc = "Live Grep (拡張子フィルター)",
      },
      {
        "<leader>fF",
        function()
          local pattern = vim.fn.input("ファイル名パターン (例: *test*, utils): ")
          pattern = pattern:match("^%s*(.-)%s*$")
          local args = { "--hidden", "--glob", "!**/.git/*" }
          if pattern ~= "" then
            if not pattern:find("%*") then
              pattern = "*" .. pattern .. "*"
            end
            table.insert(args, "--glob")
            table.insert(args, pattern)
          end
          require("telescope.builtin").live_grep({
            additional_args = args,
          })
        end,
        desc = "Live Grep (ファイル名フィルター)",
      },
      {
        "<leader>fD",
        function()
          local dir = vim.fn.input("検索ディレクトリ (例: src/components): ", "", "dir")
          dir = dir:match("^%s*(.-)%s*$")
          if dir == "" then
            require("telescope.builtin").live_grep()
          else
            require("telescope.builtin").live_grep({
              search_dirs = { dir },
            })
          end
        end,
        desc = "Live Grep (ディレクトリ指定)",
      },
      {
        "<leader>f/",
        function()
          local dir = vim.fn.input("ディレクトリ (空=全体): ", "", "dir")
          local ext = vim.fn.input("拡張子 (例: lua,py / 空=全て): ")
          local pattern = vim.fn.input("ファイル名パターン (例: test / 空=全て): ")
          dir = dir:match("^%s*(.-)%s*$")
          ext = ext:match("^%s*(.-)%s*$")
          pattern = pattern:match("^%s*(.-)%s*$")

          local args = { "--hidden", "--glob", "!**/.git/*" }
          for e in ext:gmatch("[^,]+") do
            e = e:match("^%s*(.-)%s*$")
            if e ~= "" then
              local glob = (e:sub(1,1) == "*") and e or (e:sub(1,1) == ".") and ("*"..e) or ("*."..e)
              table.insert(args, "--glob")
              table.insert(args, glob)
            end
          end
          if pattern ~= "" then
            if not pattern:find("%*") then pattern = "*" .. pattern .. "*" end
            table.insert(args, "--glob")
            table.insert(args, pattern)
          end

          require("telescope.builtin").live_grep({
            additional_args = args,
            search_dirs = dir ~= "" and { dir } or nil,
          })
        end,
        desc = "Live Grep (複合フィルター)",
      },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<C-f>"] = function(prompt_bufnr)
              -- ライブgrepウィンドウ内でのglob絞り込み
              local action_state = require("telescope.actions.state")
              local current_picker = action_state.get_current_picker(prompt_bufnr)
              local ext = vim.fn.input("追加フィルター (glob例: *.lua): ")
              ext = ext:match("^%s*(.-)%s*$")
              if ext ~= "" then
                current_picker:set_prompt(current_picker:_get_prompt() .. " -- " .. ext)
              end
            end,
          },
        },
      },
      pickers = {
        live_grep = {
          additional_args = { "--hidden", "--glob", "!**/.git/*" },
        },
        find_files = {
          hidden = true,
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      if pcall(require, "telescope._extensions.fzf") then
        telescope.load_extension("fzf")
      end
    end,
  },
}
