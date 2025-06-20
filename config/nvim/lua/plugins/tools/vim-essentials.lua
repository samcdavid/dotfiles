return {
  { "tpope/vim-vinegar" },
  { "tpope/vim-endwise" },
  { "airblade/vim-gitgutter" },
  {
    "vim-test/vim-test",
    keys = {
      { "<leader>tf", "<cmd>TestNearest<cr>", desc = "VimTest Nearest" },
      { "<leader>tF", "<cmd>TestFile<cr>", desc = "VimTest File" },
    },
  },
}