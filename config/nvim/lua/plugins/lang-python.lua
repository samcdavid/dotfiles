-- Python language support
return {
  -- Ensure Mason installs basedpyright
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "basedpyright",
      },
    },
  },

  -- Python LSP Setup
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Set up Python LSP if not already configured
      opts.servers = opts.servers or {}
      
      -- Helper function to get UV Python path
      local function get_uv_python()
        if vim.fn.executable("uv") == 1 then
          return "uv run python"
        else
          return vim.fn.exepath("python") or vim.fn.exepath("python3") or "python"
        end
      end
      
      -- Disable pyright (LazyVim's default) in favor of basedpyright
      opts.servers.pyright = { enabled = false }

      if not opts.servers.basedpyright then
        opts.servers.basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                diagnosticMode = "workspace",
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                },
              },
            },
            python = {
              pythonPath = get_uv_python(),
            },
          },
        }
      end
      
      -- Add Ruff server for Python linting and formatting
      if not opts.servers.ruff then
        opts.servers.ruff = {
          cmd = vim.fn.executable("uv") == 1 and { "uv", "run", "ruff", "server" } or { "ruff", "server" },
          init_options = {
            settings = {
              -- Enable formatting and linting
              lint = { 
                enable = true,
                preview = true,
              },
              format = { 
                enable = true,
                preview = true,
              },
              organizeImports = true,
              fixAll = true,
            },
          },
        }
      end
    end,
  },

  -- Python testing support
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      
      -- Helper function to get UV Python command
      local function get_uv_python_cmd()
        if vim.fn.executable("uv") == 1 then
          return "uv run python"
        else
          return vim.fn.exepath("python") or vim.fn.exepath("python3") or "python"
        end
      end
      
      opts.adapters["neotest-python"] = {
        -- Auto-detect test runner
        runner = "pytest",
        -- Path to Python binary for running tests
        python = get_uv_python_cmd(),
        -- Arguments for runners
        args = {
          pytest = { "-v" },
        },
      }
    end,
    ft = { "python" },
  },

  -- Python debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      config = function()
        -- Use UV Python if available
        local python_path
        if vim.fn.executable("uv") == 1 then
          python_path = "uv run python"
        else
          python_path = vim.fn.exepath("python") or vim.fn.exepath("python3") or "python"
        end
        require("dap-python").setup(python_path)
      end,
      ft = { "python" },
    }
  },

  -- Fallback formatters for projects not using Ruff
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Black formatter (fallback for projects without Ruff)
        vim.fn.executable("uv") == 1 
          and vim.fn.system("uv run which black 2>/dev/null"):find("black")
          and nls.builtins.formatting.black.with({
            command = "uv",
            args = { "run", "black", "--stdin-filename", "$FILENAME", "-" },
          })
          or (vim.fn.executable("black") == 1 and nls.builtins.formatting.black or nil),
          
        -- isort (fallback for import sorting when not using Ruff)
        vim.fn.executable("uv") == 1
          and vim.fn.system("uv run which isort 2>/dev/null"):find("isort")
          and nls.builtins.formatting.isort.with({
            command = "uv",
            args = { "run", "isort", "--stdout", "--filename", "$FILENAME", "-" },
          })
          or (vim.fn.executable("isort") == 1 and nls.builtins.formatting.isort or nil),
          
        -- pylint (fallback linter)
        vim.fn.executable("uv") == 1
          and vim.fn.system("uv run which pylint 2>/dev/null"):find("pylint")
          and nls.builtins.diagnostics.pylint.with({
            command = "uv",
            args = { "run", "pylint", "--output-format", "json", "--from-stdin", "$FILENAME" },
          })
          or (vim.fn.executable("pylint") == 1 and nls.builtins.diagnostics.pylint or nil),
      })
    end,
  },
}