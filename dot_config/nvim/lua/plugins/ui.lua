return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "catppuccin",
    opts = {
      transparent_background = true,
    },
  },
  {
    "xiyaowong/transparent.nvim",
    config = function()
      require("transparent").setup({
        extra_groups = {
          "NeoTreeNormal",
          "NeoTreeNormalNC",
          "NormalFloat",
        },
        exclude_groups = { "StatusLine" },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_z = {
          {
            function()
              return " " .. os.date("%R")
            end,
            separator = { right = "" },
            left_padding = 2,
          },
        },
      },
    },
  },
  -- Configure which-key to add icon for TidalCycles
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>t", desc = "tidal cycles", icon = { icon = "󱍙 ", color = "blue" } },
          { "<leader>te", icon = { icon = "󰝚 ", color = "blue" } },
          { "<leader>th", icon = { icon = "󰝛 ", color = "blue" } },
          { "<leader>tm", desc = "Mute Channels", icon = { icon = " ", color = "blue" } },
          { "<leader>tu", desc = "Unmute Channels", icon = { icon = " ", color = "blue" } },
          { "<leader>ts", desc = "Silence Channels", icon = { icon = "󰎊 ", color = "blue" } },
          { "<leader>j", desc = "jj", icon = { icon = " ", color = "green" } },
        },
      },
    },
  },
}
