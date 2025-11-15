return {
  -- vim-tidal for TidalCycles
  {
    "tidalcycles/vim-tidal",
    ft = "tidal",
    keys = {
      {
        "<D-e>",
        "<cmd>TidalSend<cr>",
        mode = { "i", "x", "n", "s" },
        desc = "Tidal: Evaluate",
        buffer = 0,
      },
      {
        "<D-h>",
        "<cmd>TidalHush<cr>",
        mode = { "i", "x", "n", "s" },
        desc = "Tidal: Hush",
        buffer = 0,
      },
      -- Leader key bindings
      {
        "<leader>te",
        "<cmd>TidalSend<cr>",
        mode = { "n", "v" },
        desc = "Evaluate",
        buffer = 0,
      },
      {
        "<leader>th",
        "<cmd>TidalHush<cr>",
        mode = "n",
        desc = "Hush",
        buffer = 0,
      },
      -- Channel mute keybindings (1-9)
      {
        "<leader>tm1",
        "<cmd>TidalMute1<cr>",
        mode = "n",
        desc = "Mute Channel 1",
        buffer = 0,
      },
      {
        "<leader>tm2",
        "<cmd>TidalMute2<cr>",
        mode = "n",
        desc = "Mute Channel 2",
        buffer = 0,
      },
      {
        "<leader>tm3",
        "<cmd>TidalMute3<cr>",
        mode = "n",
        desc = "Mute Channel 3",
        buffer = 0,
      },
      {
        "<leader>tm4",
        "<cmd>TidalMute4<cr>",
        mode = "n",
        desc = "Mute Channel 4",
        buffer = 0,
      },
      {
        "<leader>tm5",
        "<cmd>TidalMute5<cr>",
        mode = "n",
        desc = "Mute Channel 5",
        buffer = 0,
      },
      {
        "<leader>tm6",
        "<cmd>TidalMute6<cr>",
        mode = "n",
        desc = "Mute Channel 6",
        buffer = 0,
      },
      {
        "<leader>tm7",
        "<cmd>TidalMute7<cr>",
        mode = "n",
        desc = "Mute Channel 7",
        buffer = 0,
      },
      {
        "<leader>tm8",
        "<cmd>TidalMute8<cr>",
        mode = "n",
        desc = "Mute Channel 8",
        buffer = 0,
      },
      {
        "<leader>tm9",
        "<cmd>TidalMute9<cr>",
        mode = "n",
        desc = "Mute Channel 9",
        buffer = 0,
      },
      -- Channel silence keybindings (1-9)
      {
        "<leader>ts1",
        "<cmd>TidalSilence 1<cr>",
        mode = "n",
        desc = "Silence Channel 1",
        buffer = 0,
      },
      {
        "<leader>ts2",
        "<cmd>TidalSilence 2<cr>",
        mode = "n",
        desc = "Silence Channel 2",
        buffer = 0,
      },
      {
        "<leader>ts3",
        "<cmd>TidalSilence 3<cr>",
        mode = "n",
        desc = "Silence Channel 3",
        buffer = 0,
      },
      {
        "<leader>ts4",
        "<cmd>TidalSilence 4<cr>",
        mode = "n",
        desc = "Silence Channel 4",
        buffer = 0,
      },
      {
        "<leader>ts5",
        "<cmd>TidalSilence 5<cr>",
        mode = "n",
        desc = "Silence Channel 5",
        buffer = 0,
      },
      {
        "<leader>ts6",
        "<cmd>TidalSilence 6<cr>",
        mode = "n",
        desc = "Silence Channel 6",
        buffer = 0,
      },
      {
        "<leader>ts7",
        "<cmd>TidalSilence 7<cr>",
        mode = "n",
        desc = "Silence Channel 7",
        buffer = 0,
      },
      {
        "<leader>ts8",
        "<cmd>TidalSilence 8<cr>",
        mode = "n",
        desc = "Silence Channel 8",
        buffer = 0,
      },
      {
        "<leader>ts9",
        "<cmd>TidalSilence 9<cr>",
        mode = "n",
        desc = "Silence Channel 9",
        buffer = 0,
      },
      -- Channel unmute keybindings (1-9)
      {
        "<leader>tu1",
        "<cmd>TidalUnmute1<cr>",
        mode = "n",
        desc = "Unmute Channel 1",
        buffer = 0,
      },
      {
        "<leader>tu2",
        "<cmd>TidalUnmute2<cr>",
        mode = "n",
        desc = "Unmute Channel 2",
        buffer = 0,
      },
      {
        "<leader>tu3",
        "<cmd>TidalUnmute3<cr>",
        mode = "n",
        desc = "Unmute Channel 3",
        buffer = 0,
      },
      {
        "<leader>tu4",
        "<cmd>TidalUnmute4<cr>",
        mode = "n",
        desc = "Unmute Channel 4",
        buffer = 0,
      },
      {
        "<leader>tu5",
        "<cmd>TidalUnmute5<cr>",
        mode = "n",
        desc = "Unmute Channel 5",
        buffer = 0,
      },
      {
        "<leader>tu6",
        "<cmd>TidalUnmute6<cr>",
        mode = "n",
        desc = "Unmute Channel 6",
        buffer = 0,
      },
      {
        "<leader>tu7",
        "<cmd>TidalUnmute7<cr>",
        mode = "n",
        desc = "Unmute Channel 7",
        buffer = 0,
      },
      {
        "<leader>tu8",
        "<cmd>TidalUnmute8<cr>",
        mode = "n",
        desc = "Unmute Channel 8",
        buffer = 0,
      },
      {
        "<leader>tu9",
        "<cmd>TidalUnmute9<cr>",
        mode = "n",
        desc = "Unmute Channel 9",
        buffer = 0,
      },
    },
    config = function()
      -- vim-tidal configuration
      -- Set target to terminal (can also be "ghci" or "tmux")
      vim.g.tidal_target = "terminal"
      -- Disable SuperCollider integration (set to 1 if using SuperCollider)
      vim.g.tidal_sc_enable = 0
      -- Set filetype for .tidal files
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        pattern = "*.tidal",
        command = "set filetype=tidal",
      })

      -- Create mute functions for each channel
      for channel = 1, 9 do
        vim.api.nvim_create_user_command("TidalMute" .. channel, function()
          -- Use vim-tidal's native TidalSend1 command to send mute command
          vim.cmd("TidalSend1 mute " .. channel)
        end, { desc = "Mute channel " .. channel })
      end

      -- Create unmute functions for each channel
      for channel = 1, 9 do
        vim.api.nvim_create_user_command("TidalUnmute" .. channel, function()
          -- Use vim-tidal's native TidalSend1 command to send unmute command
          vim.cmd("TidalSend1 unmute " .. channel)
        end, { desc = "Unmute channel " .. channel })
      end
    end,
  },
}
