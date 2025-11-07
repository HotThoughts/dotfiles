-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        yamlls = {
          filetypes = { "yaml", "yml" },
          settings = {
            yaml = {
              format = {
                enable = false,
                singleQuote = true,
              },
            },
          },
        },
      },
    },
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  -- { import = "lazyvim.plugins.extras.lang." },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "query",
        "regex",
        "vim",
        "yaml",
        "helm",
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
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
}
