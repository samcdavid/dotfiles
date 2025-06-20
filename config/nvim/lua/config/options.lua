-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local function status_line()
  local mode = "%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}"
  local file_name = "%-.16t"
  local buf_nr = "[%n]"
  local modified = " %-m"
  local file_type = " %y"
  -- local right_align = "%="
  -- local line_no = "%10([%l/%L%)]"
  -- local pct_thru_file = "%5p%%"

  return string.format("%s%s%s%s%s", mode, file_name, buf_nr, modified, file_type)
end

-- vim.opt.statusline = status_line()
vim.opt.winbar = status_line()
vim.opt.swapfile = false
vim.opt.showtabline = 0
vim.opt.bufhidden = "wipe"
vim.opt.buflisted = false
