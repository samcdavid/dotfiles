-- Editor enhancement plugins
return {
  -- EditorConfig support
  "gpanders/editorconfig.nvim",

  -- Telescope with FZF
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- Treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "eex",
        "elixir",
        "heex",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "ruby",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
  },

  -- Tpope's "disease" plugins
  { "tpope/vim-vinegar", event = "VeryLazy" },
  { "tpope/vim-endwise", ft = { "ruby", "lua", "elixir", "sh", "zsh", "vim", "c", "cpp" } },
  { 
    "airblade/vim-gitgutter", 
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Neoformat for code formatting
  {
    "sbdchd/neoformat",
    cmd = "Neoformat",
    keys = {
      { "<leader>cf", "<cmd>Neoformat<cr>", desc = "Format with Neoformat" },
    },
  },
}