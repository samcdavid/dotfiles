-- Markdown language support
return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

  -- Format markdown on save with mdformat.
  --
  -- mdformat is installed standalone via pipx with the mdformat-gfm plugin
  -- injected, so the `mdformat` binary auto-enables GitHub Flavored Markdown
  -- (task lists, strikethrough, autolinks, tables) with no extra args.
  --
  -- conform runs `mdformat -` (stdin), so mdformat looks for `.mdformat.toml`
  -- by walking up from Neovim's cwd. `~/.mdformat.toml` (this repo's
  -- `mdformat.toml`, symlinked by rcm) is the fallback picked up for any file
  -- edited from within $HOME unless a project provides a closer one.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "mdformat" },
        ["markdown.mdx"] = { "mdformat" },
      },
    },
  },
}
