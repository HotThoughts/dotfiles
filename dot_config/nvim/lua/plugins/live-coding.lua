-- Live coding: TidalCycles + SuperCollider.
--
-- Two plugins working as one:
--   * tidal.nvim (MrReason, Codeberg) — the ghci/Tidal side: launch with
--     :TidalLaunch (auto on the first .tidal buffer), evaluate with <CR>
--     or <leader>te, hush with <leader>th.
--   * scnvim — the SuperCollider side: spawns sclang on TidalLaunch;
--     SuperDirt boots via the SC startup file chain
--     (~/Library/Application Support/SuperCollider/startup.scd
--       -> ~/PersonalProjects/Tidal/practice/startup.scd)
--
-- Run SC from only one place: scnvim here, or start-supercollider.sh —
-- never both; two SuperDirts fight over the same UDP port.
--
-- The old vim-tidal spec is kept commented at the bottom as a restore
-- path. tides.nvim (~/PersonalProjects/tides.nvim) is no longer loaded
-- but the repo is kept on disk.

return {
  -- The Tidal half: patterns, evaluation, event highlighting.
  {
    "https://codeberg.org/MrReason/tidal.nvim",
    init = function()
      -- Register the .tidal filetype (must exist before detection runs) and
      -- keep the sample-name dictionary (<C-x><C-k>) with the custom banks
      -- from samples/samples-extra.
      vim.filetype.add({ extension = { tidal = "tidal" } })

      local launched = false
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tidal",
        callback = function(args)
          vim.opt_local.dictionary:append(
            vim.fn.expand("~/PersonalProjects/Tidal/samples/tidal-dictionary.txt"))

          -- Auto-launch Tidal once per session: tidal.nvim fails silently
          -- until :TidalLaunch has run.
          if not launched then
            launched = true
            vim.defer_fn(function()
              pcall(vim.cmd, "TidalLaunch")
            end, 100)
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
          end
          local api = require("tidal").api
          local message = require("tidal.core.message")

          -- tidal.nvim fails silently when ghci is down; wrap sends with a
          -- visible warning instead.
          local function send(fn)
            return function(...)
              if not require("tidal.core.state").ghci then
                vim.notify("tidal.nvim: ghci not running — run :TidalLaunch", vim.log.levels.WARN)
                return
              end
              fn(...)
            end
          end

          -- Evaluate: Enter in normal mode = block (contiguous non-empty
          -- lines), plus <leader>te.
          map("n", "<CR>", send(api.send_block), "Tidal: evaluate block")
          map("n", "<leader>te", send(api.send_block), "Tidal: evaluate block")
          -- Visual mode: send the selection (Esc first so the marks survive,
          -- then reselect with gv — same trick the plugin uses).
          map("x", "<CR>", "<Esc><Cmd>lua require('tidal').api.send_visual()<CR>gv", "Tidal: evaluate selection")
          map("x", "<leader>te", "<Esc><Cmd>lua require('tidal').api.send_visual()<CR>gv", "Tidal: evaluate selection")
          -- hush all tracks
          map("n", "<leader>th", send(function() message.tidal.send_line("hush", { 0, 0 }) end), "Tidal: hush")
          -- send the expression under the cursor (needs haskell treesitter)
          map("n", "<leader>tn", send(api.send_node), "Tidal: send node")
          -- silence a channel: 2<leader>td silences d2 (default d1), or
          -- directly via <leader>td1 .. <leader>td9
          map("n", "<leader>td", send(api.send_silence), "Tidal: silence channel")
          for channel = 1, 9 do
            map("n", "<leader>td" .. channel, send(function()
              message.tidal.send_line(("d%d silence"):format(channel), { 0, 0 })
            end), "Tidal: silence d" .. channel)
          end
          -- session control + the rest of the API surface
          map("n", "<leader>tl", "<cmd>TidalLaunch<cr>", "Tidal: launch")
          map("n", "<leader>tq", "<cmd>TidalQuit<cr>", "Tidal: quit")
          map("n", "<leader>tp", "<cmd>TidalNotification<cr>", "Tidal: post window")
          map("n", "<leader>tx", send(function()
            vim.ui.input({ prompt = "tidal> " }, function(expr)
              if expr and expr ~= "" then
                api.send(expr)
              end
            end)
          end), "Tidal: send expression")
        end,
      })

      -- Fix event highlighting: tidal.nvim loads tidal/playstate.hs (which
      -- defines `clock`, needed for the event stream) by writing
      -- `:{ :script "<path>" :}` to ghci — but ghci rejects commands inside
      -- a :{ :} block, so `clock` is never defined ("Variable not in scope:
      -- clock"). Load the script content directly via stdin instead;
      -- ghci buffers stdin while still compiling the boot file, so an
      -- immediate write is safe and ordered after the boot script.
      vim.api.nvim_create_autocmd("User", {
        pattern = "TidalLaunch",
        callback = function()
          local ghci = require("tidal.core.state").ghci
          if not ghci or not ghci.stdin then
            vim.notify("tides-fix: ghci not ready — playstate.hs not loaded", vim.log.levels.WARN)
            return
          end
          local path = vim.api.nvim_get_runtime_file("tidal/playstate.hs", false)[1]
          if not path then
            vim.notify("tides-fix: playstate.hs not found in runtime path", vim.log.levels.ERROR)
            return
          end
          ghci.stdin:write(table.concat(vim.fn.readfile(path), "\n") .. "\n")
        end,
      })
    end,
    opts = {
      --- Configure TidalLaunch command
      boot = {
        tidal = {
          --- Command to launch ghci with tidal installation
          cmd = vim.fn.expand("~/.ghcup/bin/ghci"), -- ghcup is not on PATH
          args = {
            "-v0",
          },
          --- Tidal boot file path — omitted to use the plugin's bundled
          --- bootfiles/BootTidal.hs, which defines deltaContext and the
          --- clock target needed by event highlighting
          -- file = "/path/to/BootTidal.hs",
          enabled = true,
          highlight = {
            styles = {
              osc = {
                ip = "127.0.0.1",
                port = 3335,
              },
              -- [Tidal ID] -> hl style
              custom = {
                ["drums"] = { bg = "#e7b9ed", foreground = "#000000" },
                ["2"] = { bg = "#b9edc7", foreground = "#000000" },
              },
              global = { baseName = "CodeHighlight", style = { bg = "#7eaefc", foreground = "#000000" } },
            },
            events = {
              osc = {
                ip = "127.0.0.1",
                port = 6013,
              },
            },
            fps = 30,
          },
        },
        split = "v",
      },
      --- Keymaps. Our explicit keymaps (attached per-buffer in the FileType
      --- autocmd above) cover send_block/send_visual/send_node/send_silence/
      --- send_hush, so the plugin's own entries for those are disabled to
      --- avoid double-mapping. Its <S-CR> send-line default remains.
      mappings = {
        send_line = { mode = { "i", "n" }, key = "<S-CR>" },
        send_block = false,
        send_visual = false,
        send_node = false,
        send_silence = false,
        send_hush = false,
      },
      ---- Configure highlight applied to selections sent to tidal interpreter
      selection_highlight = {
        --- Highlight definition table
        --- see ':h nvim_set_hl' for details
        --- @type vim.api.keyset.highlight
        highlight = { link = "IncSearch" },
        --- Duration to apply the highlight for
        timeout = 150,
      },
    },
    dependencies = {
      -- Required for the send-node mapping and Haskell highlighting.
      { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "haskell" } } },
    },
  },

  -- The SuperCollider half: sclang + SuperDirt, started on TidalLaunch.
  {
    "davidgranstrom/scnvim",
    lazy = false, -- small; loaded eagerly so the TidalLaunch autocmd is ready
    config = function()
      local scnvim = require("scnvim")
      scnvim.setup({
        sclang = {
          -- Not on PATH; lives inside the app bundle
          cmd = "/Applications/SuperCollider.app/Contents/MacOS/sclang",
        },
        -- Post window along the bottom, like the old terminal layout
        postwin = {
          horizontal = true,
          direction = "bot",
          size = 14,
        },
      })

      -- Start SuperCollider whenever Tidal launches. TidalLaunch fires at
      -- most once per session (tidal.nvim guards it), so no extra guard is
      -- needed here.
      vim.api.nvim_create_autocmd("User", {
        pattern = "TidalLaunch",
        callback = function()
          scnvim.start()
        end,
      })
    end,
  },

  --[=[
  -- vim-tidal for TidalCycles
  {
    "tidalcycles/vim-tidal",
    ft = "tidal",
    keys = {
      -- Custom keymaps: <C-e> for line send, <C-r> for paragraph send
      {
        "<D-e>",
        "<Plug>TidalLineSend",
        mode = { "i", "x", "n", "s" },
        desc = "Tidal: Send line",
        buffer = 0,
      },
      {
        "<D-r>",
        "<Plug>TidalParagraphSend",
        mode = { "i", "x", "n", "s" },
        desc = "Tidal: Evaluate paragraph",
        buffer = 0,
      },
      -- Leader key bindings
      {
        "<leader>te",
        "<Plug>TidalParagraphSend",
        mode = "n",
        desc = "Evaluate paragraph",
        buffer = 0,
      },
      {
        "<leader>te",
        "<Plug>TidalRegionSend",
        mode = "v",
        desc = "Evaluate selection",
        buffer = 0,
      },
      -- Enter evaluates (buffer-local to tidal buffers):
      -- normal mode = paragraph, visual mode = selection.
      -- Same targets as <leader>te; overrides nvim's default <CR>
      -- ("move down a line") only inside .tidal files.
      {
        "<CR>",
        "<Plug>TidalParagraphSend",
        mode = "n",
        desc = "Evaluate paragraph",
        buffer = 0,
      },
      {
        "<CR>",
        "<Plug>TidalRegionSend",
        mode = "v",
        desc = "Evaluate selection",
        buffer = 0,
      },
      {
        "<leader>th",
        "<cmd>TidalHush<cr>",
        mode = "n",
        desc = "Hush",
        buffer = 0,
      },
      {
        "<leader>tp",
        "<cmd>TidalSend1 panic<cr>",
        mode = "n",
        desc = "Panic (hush + stop)",
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
      -- Target: nvim terminal splits (ghci REPL + SuperCollider)
      vim.g.tidal_target = "terminal"
      -- Boot SuperCollider alongside the Tidal REPL
      vim.g.tidal_sc_enable = 1
      -- Absolute paths so booting works no matter how nvim was launched
      -- (ghcup is not on PATH; sclang lives inside the .app bundle)
      vim.g.tidal_ghci = vim.fn.expand("~/.ghcup/bin/ghci")
      vim.g.tidal_sclang = "/Applications/SuperCollider.app/Contents/MacOS/sclang"
      -- Bare sclang: SuperDirt boots via the SC startup file chain
      -- (platform startup.scd -> practice/startup.scd)
      vim.g.tidal_sc_boot_cmd = vim.g.tidal_sclang
      -- Disable vim-tidal's default mappings so we can use our custom ones
      vim.g.tidal_no_mappings = 1

      -- Open a .tidal file and both terminal splits boot automatically:
      -- vim-tidal opens them on the first send, so sending a harmless `hush`
      -- right away triggers the boot. Run once per session so re-opening
      -- files does not re-send.
      -- Also register the sample-name dictionary (<C-x><C-k>) which includes
      -- the custom banks from samples/samples-extra.
      local sc_autobooted = false
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tidal",
        callback = function()
          vim.opt_local.dictionary:append(
            vim.fn.expand("~/PersonalProjects/Tidal/samples/tidal-dictionary.txt"))
          if not sc_autobooted then
            sc_autobooted = true
            vim.defer_fn(function()
              pcall(vim.cmd, "TidalSend1 hush")
            end, 200)
          end
        end,
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
  ]=]
}
