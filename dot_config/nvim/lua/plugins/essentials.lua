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
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = "Liminal Forge",
          path = "/Users/hotthoughts/Library/Mobile Documents/iCloud~md~obsidian/Documents/Liminal Forge",
        },
      },

      -- see below for full list of options 👇
    },
  },
  {
    "HotThoughts/jjui.nvim",
    cmd = {
      "JJUI",
      "JJUICurrentFile",
      "JJUIFilter",
      "JJUIFilterCurrentFile",
      "JJConfig",
    },
    -- Setting the keybinding here helps lazy-loading
    keys = {
      { "<leader>jj", "<cmd>JJUI<cr>", desc = "JJUI" },
      { "<leader>jc", "<cmd>JJUICurrentFile<cr>", desc = "JJUI (current file)" },
      { "<leader>jl", "<cmd>JJUIFilter<cr>", desc = "JJUI Log" },
      { "<leader>jf", "<cmd>JJUIFilterCurrentFile<cr>", desc = "JJUI Log (current file)" },
    },
    config = function()
      require("jjui").setup({
        -- configuration options (see below)
      })
    end,
  },
}
