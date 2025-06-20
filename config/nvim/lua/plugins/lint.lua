return {
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
}
