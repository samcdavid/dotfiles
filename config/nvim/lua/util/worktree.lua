-- Worktree-aware utilities for root detection
-- Handles git worktrees properly by detecting the actual worktree root
-- instead of the main repository root

local M = {}

--- Get the git worktree root for a given path
--- In a worktree, .git is a file containing "gitdir: /path/to/.git/worktrees/name"
--- This function returns the actual worktree root, not the main repo root
---@param path string? The path to check (defaults to current buffer or cwd)
---@return string|nil The worktree root path, or nil if not in a git repo
function M.get_worktree_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end

  -- Start from the file's directory
  local dir = vim.fn.fnamemodify(path, ":p:h")

  -- Walk up the directory tree looking for .git
  while dir ~= "/" do
    local git_path = dir .. "/.git"
    local stat = vim.loop.fs_stat(git_path)

    if stat then
      if stat.type == "directory" then
        -- Regular git repo (not a worktree)
        return dir
      elseif stat.type == "file" then
        -- This is a worktree - .git is a file pointing to the main repo
        -- The worktree root is this directory
        return dir
      end
    end

    -- Move up one directory
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return nil
end

--- Check if current directory is inside a git worktree (not the main repo)
---@param path string? The path to check
---@return boolean
function M.is_worktree(path)
  path = path or vim.fn.getcwd()
  local dir = vim.fn.fnamemodify(path, ":p:h")

  while dir ~= "/" do
    local git_path = dir .. "/.git"
    local stat = vim.loop.fs_stat(git_path)

    if stat then
      -- If .git is a file, we're in a worktree
      return stat.type == "file"
    end

    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return false
end

--- Create a root pattern function that respects worktree boundaries
--- Unlike lspconfig.util.root_pattern, this won't traverse above the worktree root
---@param ... string Patterns to match (e.g., "mix.exs", "package.json")
---@return function A root detection function
function M.root_pattern(...)
  local patterns = { ... }
  local lsputil = require("lspconfig.util")

  return function(fname)
    -- First, find the worktree/git root as an upper bound
    local worktree_root = M.get_worktree_root(fname)

    -- Find the pattern match
    local pattern_root = lsputil.root_pattern(unpack(patterns))(fname)

    if pattern_root and worktree_root then
      -- Ensure we don't go above the worktree root
      -- The pattern root should be within or equal to the worktree root
      if vim.startswith(pattern_root, worktree_root) or pattern_root == worktree_root then
        return pattern_root
      else
        -- Pattern found above worktree root, use worktree root instead
        return worktree_root
      end
    elseif worktree_root then
      return worktree_root
    elseif pattern_root then
      return pattern_root
    end

    return vim.fn.getcwd()
  end
end

--- Get the path for use with git commands in worktrees
--- Returns arguments suitable for git -C or sets GIT_DIR appropriately
---@param path string? The path to check
---@return string The worktree root path
function M.git_cwd(path)
  return M.get_worktree_root(path) or vim.fn.getcwd()
end

return M
