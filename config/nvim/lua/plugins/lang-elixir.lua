-- Elixir language support
return {
  -- Elixir LSP Setup
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Set up Elixir LSP if not already configured
      opts.servers = opts.servers or {}
      local worktree = require("util.worktree")

      if not opts.servers.lexical then
        opts.servers.lexical = {
          cmd = { "/Users/sammcdavid/Developer/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
          filetypes = { "elixir", "eelixir", "heex" },
          -- Use worktree-aware root detection
          -- Prioritize mix.exs but respect worktree boundaries
          root_dir = worktree.root_pattern("mix.exs"),
          settings = {},
        }
      end
    end,
  },

  -- Elixir testing support
  {
    "nvim-neotest/neotest",
    dependencies = {
      "jfpedroza/neotest-elixir",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-elixir"] = {}
    end,
  },

  -- Credo integration for none-ls
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      if vim.fn.executable("credo") == 1 then
        local nls = require("null-ls")
        opts.sources = vim.list_extend(opts.sources or {}, {
          nls.builtins.diagnostics.credo,
        })
      end
    end,
  },
}