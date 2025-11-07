return {
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
}
