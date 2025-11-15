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
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["yaml"] = { "yamlfix" },
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
