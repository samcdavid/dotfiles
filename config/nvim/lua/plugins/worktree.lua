-- Worktree support for monorepos and git worktrees
-- Ensures Telescope and other tools respect worktree boundaries
--
-- LazyVim root detection uses vim.g.root_spec with these entry types:
-- - Detector function names like "lsp" or "cwd"
-- - Patterns like ".git" or { ".git", "lua" }
-- - Custom functions: function(buf) -> string|string[]

-- Set up worktree-aware root detection before plugins load
-- This creates a custom "worktree" detector for LazyVim
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local worktree = require("util.worktree")

    -- Register worktree as a custom root detector
    local LazyVimRoot = require("lazyvim.util.root")
    if LazyVimRoot and LazyVimRoot.detectors then
      LazyVimRoot.detectors.worktree = function(buf)
        local bufname = buf and vim.api.nvim_buf_get_name(buf) or nil
        local root = worktree.get_worktree_root(bufname)
        return root and { root } or {}
      end
    end
  end,
})

-- Configure root_spec to prioritize worktree detection
-- Order: worktree boundary -> LSP -> project files -> cwd
vim.g.root_spec = {
  -- Custom worktree detector (registered above)
  function(buf)
    local ok, worktree = pcall(require, "util.worktree")
    if ok then
      local bufname = buf and vim.api.nvim_buf_get_name(buf) or nil
      local root = worktree.get_worktree_root(bufname)
      if root then
        return { root }
      end
    end
    return {}
  end,
  -- Then check LSP roots (but they should be within worktree)
  "lsp",
  -- Project file patterns as fallback
  { ".git", "mix.exs", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
  -- Final fallback to cwd
  "cwd",
}

return {
  -- Git worktree management
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      change_directory_command = "cd",
      update_on_change = true,
      update_on_change_command = "e .",
      clearjumps_on_change = true,
      autopush = false,
    },
    keys = {
      {
        "<leader>gw",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Git Worktrees",
      },
      {
        "<leader>gW",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Create Git Worktree",
      },
    },
  },

  -- Configure Telescope to respect worktree boundaries and load git_worktree extension
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "ThePrimeagen/git-worktree.nvim" },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("git_worktree")
    end,
    opts = function(_, opts)
      local worktree = require("util.worktree")

      -- Helper to get the correct cwd for telescope pickers
      local function get_telescope_cwd()
        return worktree.get_worktree_root() or vim.fn.getcwd()
      end

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        -- Use worktree root as the default cwd for all pickers
        cwd = get_telescope_cwd,
      })

      -- Configure specific pickers to respect worktree boundaries
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = {
          -- Search from worktree root, not git repo root
          cwd = get_telescope_cwd,
          -- Only search tracked and untracked files within worktree
          find_command = function()
            local root = get_telescope_cwd()
            -- Use git ls-files and git ls-files --others to stay within worktree
            if vim.fn.isdirectory(root .. "/.git") == 1 or vim.fn.filereadable(root .. "/.git") == 1 then
              return { "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard" }
            end
            -- Fallback to fd/find if not in git
            if vim.fn.executable("fd") == 1 then
              return { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
            end
            return { "find", ".", "-type", "f", "-not", "-path", "*/.git/*" }
          end,
        },
        git_files = {
          cwd = get_telescope_cwd,
          -- Explicitly set git_command to use -C flag for worktree support
          git_command = function()
            local root = get_telescope_cwd()
            return { "git", "-C", root, "ls-files", "--exclude-standard", "--cached" }
          end,
        },
        live_grep = {
          cwd = get_telescope_cwd,
          -- Additional args to respect worktree
          additional_args = function()
            return { "--hidden", "--glob", "!.git" }
          end,
        },
        grep_string = {
          cwd = get_telescope_cwd,
        },
      })

      return opts
    end,
    keys = {
      -- Override default LazyVim keymaps to use worktree-aware versions
      {
        "<leader>ff",
        function()
          local worktree = require("util.worktree")
          require("telescope.builtin").find_files({ cwd = worktree.get_worktree_root() })
        end,
        desc = "Find Files (Worktree)",
      },
      {
        "<leader>fg",
        function()
          local worktree = require("util.worktree")
          require("telescope.builtin").live_grep({ cwd = worktree.get_worktree_root() })
        end,
        desc = "Grep (Worktree)",
      },
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.getcwd() })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>fG",
        function()
          require("telescope.builtin").live_grep({ cwd = vim.fn.getcwd() })
        end,
        desc = "Grep (cwd)",
      },
      -- Search within current buffer's directory
      {
        "<leader>f.",
        function()
          local dir = vim.fn.expand("%:p:h")
          require("telescope.builtin").find_files({ cwd = dir })
        end,
        desc = "Find Files (buffer dir)",
      },
    },
  },
}
