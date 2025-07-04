return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lexical = {
          cmd = { vim.fn.expand("~/.local/share/nvim/lexical/_build/dev/package/lexical/bin/start_lexical.sh") },
          settings = {},
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "jfpedroza/neotest-elixir",
    },
    opts = {
      adapters = {
        ["neotest-elixir"] = {},
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.fn.executable("credo") == 0 then
        return
      end
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.credo,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      if vim.fn.executable("credo") == 0 then
        return
      end
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.elixir = { "credo" }
    end,
  },
}