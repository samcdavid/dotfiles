-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-cd to worktree root when opening neovim in a worktree
-- This ensures that cwd is the worktree root, not the main repo
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only run once at startup
    local cwd = vim.fn.getcwd()
    local git_path = cwd .. "/.git"
    local stat = vim.loop.fs_stat(git_path)

    -- If .git is a file, we're in a worktree - find the actual worktree root
    if stat and stat.type == "file" then
      -- We're already in the worktree root since .git file is here
      -- No need to change directory
      return
    end

    -- Check if we started from a subdirectory of a worktree
    local dir = cwd
    while dir ~= "/" do
      local check_git = dir .. "/.git"
      local check_stat = vim.loop.fs_stat(check_git)
      if check_stat and check_stat.type == "file" then
        -- Found worktree root above us, but don't auto-cd
        -- The user explicitly started from a subdirectory
        return
      end
      dir = vim.fn.fnamemodify(dir, ":h")
    end
  end,
  desc = "Detect worktree on startup",
})

-- Format Python files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    -- Use LSP formatting if available (Ruff LSP or null-ls)
    vim.lsp.buf.format({
      async = false,
      timeout_ms = 3000,
    })
  end,
  desc = "Format Python files on save",
})

-- Set colorcolumn based on .editorconfig max_line_length
local function set_colorcolumn_from_editorconfig()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return
  end
  
  local bufdir = vim.fn.fnamemodify(bufname, ":h")
  
  -- Function to parse .editorconfig file
  local function parse_editorconfig(filepath)
    local file = io.open(filepath, "r")
    if not file then
      return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    local config = {}
    local current_section = nil
    
    for line in content:gmatch("[^\r\n]+") do
      line = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
      
      if line:match("^%[.+%]$") then
        -- Section header
        current_section = line:sub(2, -2) -- remove brackets
      elseif line:match("^[^=]+=[^=]+$") and current_section then
        -- Key-value pair
        local key, value = line:match("^([^=]+)=([^=]+)$")
        if key and value then
          key = key:gsub("^%s+", ""):gsub("%s+$", "")
          value = value:gsub("^%s+", ""):gsub("%s+$", "")
          
          if not config[current_section] then
            config[current_section] = {}
          end
          config[current_section][key] = value
        end
      end
    end
    
    return config
  end
  
  -- Function to check if file matches glob pattern
  local function matches_glob(filename, pattern)
    -- Simple glob matching for common cases
    if pattern == "*" then
      return true
    elseif pattern:sub(1, 1) == "*" and pattern:sub(-1) == "*" then
      -- *pattern*
      local middle = pattern:sub(2, -2)
      return filename:find(middle, 1, true) ~= nil
    elseif pattern:sub(1, 1) == "*" then
      -- *.ext
      local ext = pattern:sub(2)
      return filename:sub(-#ext) == ext
    elseif pattern:sub(-1) == "*" then
      -- prefix*
      local prefix = pattern:sub(1, -2)
      return filename:sub(1, #prefix) == prefix
    else
      -- exact match
      return filename == pattern
    end
  end
  
  -- Find .editorconfig files up the directory tree
  local current_dir = bufdir
  local max_line_length = nil
  
  while current_dir ~= "/" do
    local editorconfig_path = current_dir .. "/.editorconfig"
    local config = parse_editorconfig(editorconfig_path)
    
    if config then
      local filename = vim.fn.fnamemodify(bufname, ":t")
      local relative_path = vim.fn.fnamemodify(bufname, ":.")
      
      -- Check sections in reverse order (most specific first)
      local sections = {}
      for section, _ in pairs(config) do
        table.insert(sections, section)
      end
      table.sort(sections, function(a, b) return #a > #b end)
      
      for _, section in ipairs(sections) do
        if matches_glob(filename, section) or matches_glob(relative_path, section) then
          if config[section].max_line_length then
            max_line_length = tonumber(config[section].max_line_length)
            break
          end
        end
      end
      
      if max_line_length then
        break
      end
      
      -- Check if this .editorconfig is root
      if config.root and config.root:lower() == "true" then
        break
      end
    end
    
    -- Move up one directory
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end
  
  -- Set colorcolumn if max_line_length was found
  if max_line_length and max_line_length > 0 then
    vim.wo.colorcolumn = tostring(max_line_length)
  else
    -- Clear colorcolumn if no max_line_length found
    vim.wo.colorcolumn = ""
  end
end

-- Set colorcolumn when entering a buffer
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  callback = set_colorcolumn_from_editorconfig,
  desc = "Set colorcolumn from .editorconfig max_line_length",
})
