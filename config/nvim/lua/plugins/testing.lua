-- Testing and linting plugins
return {
  -- Vim Test
  {
    "vim-test/vim-test",
    keys = {
      { "<leader>tf", "<cmd>TestNearest<cr>", desc = "Test Nearest" },
      { "<leader>tF", "<cmd>TestFile<cr>", desc = "Test File" },
      { "<leader>ta", "<cmd>TestSuite<cr>", desc = "Test Suite" },
      { "<leader>tl", "<cmd>TestLast<cr>", desc = "Test Last" },
      { "<leader>tg", "<cmd>TestVisit<cr>", desc = "Test Visit" },
    },
    config = function()
      vim.g['test#strategy'] = "neovim"
      
      -- Configure pytest to use UV when available
      if vim.fn.executable("uv") == 1 then
        vim.g['test#python#pytest#executable'] = 'uv run pytest'
        vim.g['test#python#runner'] = 'pytest'
      end
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      
      -- Add Elixir linting with credo if available
      if vim.fn.executable("credo") == 1 then
        opts.linters_by_ft.elixir = { "credo" }
      end
    end,
  },
}