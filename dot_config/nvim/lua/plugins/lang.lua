return {
  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "actionlint",
        "gofumpt",
        "goimports",
        "gopls",
        "hadolint",
        "helm-ls",
        "json-lsp",
        "taplo",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["yaml"] = { "yamlfix" },
        ["toml"] = { "taplo" },
      },
      formatters = {
        yamlfix = {
          env = {
            YAMLFIX_preserve_quotes = true,
            YAMLFIX_WHITELINES = "1",
            YAMLFIX_EXPLICIT_START = false,
            YAMLFIX_SEQUENCE_STYLE = "block_style",
          },
        },
        taplo = {
          -- Configure taplo formatter options
          -- See: https://taplo.tamasfe.dev/cli/usage/formatting.html
          args = {
            "format",
            "--stdin-filepath",
            "$FILENAME",
            "--indent-tables", -- Indent table entries
            "--indent-entries", -- Indent array entries
            "--array-trailing-comma", -- Add trailing commas in arrays
            "--column-width", "100", -- Set column width
            "--align-entries", -- Align entries in tables
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {
          "markdownlint",
        },
      },
      linters = {
        markdownlint = {
          args = {
            "--disable",
            "MD041",
            "--disable",
            "MD013",
          },
        },
      },
    },
  },
}
