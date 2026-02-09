-- TypeScript language support
return {
  -- TypeScript LSP Setup using typescript.nvim
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
    },
    init = function()
      local function on_attach(client, buffer)
        -- Add TypeScript specific keymaps
        vim.keymap.set(
          "n",
          "<leader>co",
          "<cmd>TypescriptOrganizeImports<cr>",
          { buffer = buffer, desc = "Organize Imports" }
        )
        vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<cr>", { desc = "Rename File", buffer = buffer })
        vim.keymap.set(
          "n",
          "<leader>ci",
          "<cmd>TypescriptAddMissingImports<cr>",
          { desc = "Add Missing Imports", buffer = buffer }
        )
        vim.keymap.set(
          "n",
          "<leader>cu",
          "<cmd>TypescriptRemoveUnused<cr>",
          { desc = "Remove Unused Imports", buffer = buffer }
        )
        vim.keymap.set("n", "<leader>cf", "<cmd>TypescriptFixAll<cr>", { desc = "Fix All", buffer = buffer })
      end
      
      -- Add this to the on_attach callback for TypeScript LSP
      require("lspconfig").tsserver.setup({
        on_attach = on_attach
      })
    end,
    opts = function(_, opts)
      -- Set up TypeScript LSP if not already configured
      opts.servers = opts.servers or {}

      if not opts.servers.tsserver then
        opts.servers.tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        }
      end

      -- Set up custom handler for tsserver
      opts.setup = opts.setup or {}
      opts.setup.tsserver = function(_, server_opts)
        require("typescript").setup({ server = server_opts })
        return true
      end
    end,
    ft = { "typescript", "typescriptreact", "typescript.tsx" },
  },

  -- TypeScript testing support
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      -- Configure Jest for TypeScript projects
      opts.adapters["neotest-jest"] = {
        jestCommand = "npm test --",
        jestConfigFile = function()
          local files = {
            "jest.config.ts",
            "jest.config.js",
          }
          for _, file in ipairs(files) do
            local file_path = vim.fn.getcwd() .. "/" .. file
            if vim.fn.filereadable(file_path) == 1 then
              return file
            end
          end
          return "jest.config.js"
        end,
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      }
    end,
    ft = { "typescript", "typescriptreact", "typescript.tsx" },
  },

  -- Enhanced TypeScript syntax via Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
      end
    end,
  },

  -- Formatter setup via null-ls/none-ls
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Add prettier formatter if executable
        vim.fn.executable("prettier") == 1
            and nls.builtins.formatting.prettier.with({
              filetypes = {
                "typescript",
                "typescriptreact",
                "typescript.tsx",
              },
              prefer_local = "node_modules/.bin",
            })
          or nil,
        -- Add ESLint for TypeScript
        vim.fn.executable("eslint_d") == 1
            and nls.builtins.diagnostics.eslint_d.with({
              filetypes = {
                "typescript",
                "typescriptreact",
                "typescript.tsx",
              },
            })
          or nil,
      })
    end,
  },
}
