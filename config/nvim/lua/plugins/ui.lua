-- UI related plugins
return {
  -- Theme
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require('onedark').setup {
        style = 'darker' -- Options: dark, darker, cool, deep, warm, warmer
      }
      require('onedark').load()
    end
  },

  -- Todo comments highlighting
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    event = "VeryLazy",
  },
}