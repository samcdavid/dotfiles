return {
  "snrogers/mermaider.nvim",
  dependencies = {
    "3rd/image.nvim",
  },
  ft = { "mmd", "mermaid", "markdown" },
  cmd = { "MermaiderRender", "MermaiderPreview", "MermaiderToggle" },
  keys = {
    { "<leader>Mt", "<cmd>MermaiderToggle<cr>", desc = "Mermaid Toggle" },
    { "<leader>Mr", "<cmd>MermaiderRender<cr>", desc = "Mermaid Render" },
    { "<leader>Mp", "<cmd>MermaiderPreview<cr>", desc = "Mermaid Preview" },
  },
  opts = {
    auto_render = true,
    auto_render_on_open = true,
    auto_preview = true,
    theme = "dark",
    inline_render = true,
    use_split = true,
    split_direction = "vertical",
  },
}
