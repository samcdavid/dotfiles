return {
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+/%d+" },
              { find = "; #" },
              { find = "; %" },
              { find = "search hit BOTTOM" },
              { find = "search hit TOP" },
              { find = "treesitter" },
              { find = "no parser" },
              { find = "invalid regex" },
              { find = "Error parsing" },
              { find = "vim.treesitter" },
              { find = "query.*error" },
              { find = "Query error at.*Invalid node type" },
              { find = "decor_provider_error.*nvim.treesitter.highlighter" },
              { find = "Error executing lua.*highlighter.lua" },
            },
          },
          view = "mini",
        },
        {
          filter = {
            any = {
              { find = "query%.lua:373" },
              { find = "Invalid node type" },
              { find = "treesitter.*highlighter" },
            },
          },
          opts = { skip = true },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
        cmdline = false,
      },
    },
  },
}