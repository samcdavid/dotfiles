return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup({
      nextls = {
        enable = false,
        port = 9000,
        init_options = {
          mix_env = "dev",
          mix_target = "host",
          experimental = {
            completions = {
              enable = true,
            },
          },
        },
      },
      credo = { enable = true },
      elixirls = {
        enable = true,
        settings = elixirls.settings({
          autoBuild = true,
          signatureAfterComplete = true,
          dialyzerEnabled = false,
          enableTestLenses = true,
        }),
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<_>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("n", "<_>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("v", "<_>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })

          -- vim.api.nvim_command("au BufWrite Post *.ex,*.exs,*.heex,*.eex lua vim.lsp.buf.format()")
        end,
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "williamboman/mason.nvim",
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "elixir-ls",
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
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
      opts.linters_by_ft = {
        elixir = { "credo" },
      }
    end,
  },
}
