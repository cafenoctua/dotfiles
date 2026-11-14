return {
  -- call hierarchy (呼び出し元/呼び出し先) を Trouble のリストで表示
  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>ci", "<cmd>Trouble lsp_incoming_calls toggle<cr>", desc = "Incoming Calls (Trouble)" },
      { "<leader>co", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", desc = "Outgoing Calls (Trouble)" },
    },
  },
}
