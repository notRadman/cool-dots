return {
  {
    "brianhuster/live-preview.nvim",
    cmd = { "LivePreview" },
    ft = { "markdown" },
    opts = {
      port = 5500,
      browser = "brave-browser-stable",
    },
    keys = {
      { "<leader>mp", "<cmd>LivePreview start<cr>", desc = "Markdown Preview" },
      { "<leader>ms", "<cmd>LivePreview close<cr>", desc = "Stop Preview" },
    },
  },
}
