-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Built-in undotree (Neovim 0.12+ ships it as an optional package; the
-- :Undotree command doesn't exist until the pack is loaded).
vim.cmd("packadd nvim.undotree")

-- Line spacing (spacing between lines)
-- Increase this value for more space between lines
vim.opt.linespace = 2 -- Adjust this value (0 = default, higher = more space)
