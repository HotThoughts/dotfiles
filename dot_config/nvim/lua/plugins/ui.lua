-- One which-key entry per tidal silence channel (<leader>td1 .. td9);
-- unpacked into the spec below (must stay the last entry).
local silence_channels = {}
for i = 1, 9 do
  table.insert(silence_channels, { ("<leader>td%d"):format(i), desc = "silence d" .. i })
end

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
          { "<leader>te", desc = "evaluate (block/selection)", icon = { icon = "󰝚 ", color = "blue" } },
          { "<leader>th", desc = "hush (tidal)", icon = { icon = "󰝛 ", color = "blue" } },
          { "<leader>tn", desc = "send node", icon = { icon = "󰎇 ", color = "blue" } },
          { "<leader>td", desc = "silence channel", icon = { icon = "󰎊 ", color = "blue" } },
          { "<leader>tl", desc = "launch tidal", icon = { icon = "󱓞 ", color = "blue" } },
          { "<leader>tq", desc = "quit tidal", icon = { icon = "󰅖 ", color = "blue" } },
          { "<leader>tp", desc = "post window", icon = { icon = "", color = "blue" } },
          { "<leader>tx", desc = "send expression", icon = { icon = "󰎍 ", color = "blue" } },
          { "<leader>j", desc = "jj", icon = { icon = " ", color = "green" } },
          unpack(silence_channels),
        },
      },
    },
  },
}
