return {
  -- Treesitter already handles syntax
  -- This is just for Flutter-specific settings
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        -- Disable LSP
        lsp = {
          enable = false,  -- We don't want LSP
        },
        -- Basic commands only
        flutter_path = nil,  -- Will find Flutter automatically
        flutter_lookup_cmd = nil,
        widget_guides = {
          enabled = false,
        },
        closing_tags = {
          enabled = true,  -- Auto-close tags
        },
        dev_log = {
          enabled = false,
        },
      })
    end,
  },
}
