return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = true,
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
}
