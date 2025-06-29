return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" } })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      javascriptreact = { { "prettierd", "prettier" } },
      typescriptreact = { { "prettierd", "prettier" } },
      json = { { "prettierd", "prettier" } },
      html = { { "prettierd", "prettier" } },
      css = { { "prettierd", "prettier" } },
      scss = { { "prettierd", "prettier" } },
      yaml = { "yamllint" },
      markdown = { { "prettierd", "prettier" } },
      python = { "black", "isort" },
      elixir = { "mix" },
      sh = { "shfmt" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}