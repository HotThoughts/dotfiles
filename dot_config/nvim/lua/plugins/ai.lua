return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      {
        "<leader>am",
        function()
          return vim.cmd("CopilotChatModels")
        end,
        desc = "Select Models (CopilotChatModels)",
        mode = { "n", "v" },
      },
      -- {
      --   "<leader>as",
      --   function()
      --     local input = vim.fn.input("Perplexity: ")
      --     if input ~= "" then
      --       require("CopilotChat").ask(input, {
      --         agent = "perplexityai",
      --         selection = false,
      --       })
      --     end
      --   end,
      --   desc = "Perplexity Search (CopilotChat)",
      --   mode = { "n", "v" },
      -- },
    },
  },
}
