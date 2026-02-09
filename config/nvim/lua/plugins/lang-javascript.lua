-- JavaScript language support
return {
  -- JavaScript/Node LSP Setup
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Set up JavaScript LSP if not already configured
      opts.servers = opts.servers or {}

      -- Configure eslint
      if not opts.servers.eslint then
        opts.servers.eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            format = true,
            lint = true,
          },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "vue",
          },
          root_dir = require("lspconfig").util.root_pattern(
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.json",
            ".eslintrc.cjs",
            "eslint.config.js",
            "package.json"
          ),
        }
      end

      -- Configure standard js server
      if vim.fn.executable("standardjs") == 1 and not opts.servers.standardjs then
        opts.servers.standardjs = {
          root_dir = require("lspconfig").util.root_pattern("package.json"),
        }
      end
    end,
  },

  -- JavaScript testing support
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-jest"] = {
        jestCommand = "npm test --",
        jestConfigFile = "jest.config.js",
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      }
    end,
    ft = { "javascript", "javascriptreact", "javascript.jsx" },
  },

  -- Prettier formatter setup via null-ls/none-ls
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Add prettier formatter if executable
        vim.fn.executable("prettier") == 1 and nls.builtins.formatting.prettier or nil,
        -- Add ESLint for linting if executable
        vim.fn.executable("eslint") == 1 and nls.builtins.diagnostics.eslint or nil,
      })
    end,
  },
}
