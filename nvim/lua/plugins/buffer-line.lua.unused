return {
  'akinsho/bufferline.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = false,
      },
      highlights = {
        fill = { bg = "NONE" },
        background = { bg = "NONE" },
        buffer_selected = { bold = true, italic = false },
        separator = { fg = "NONE", bg = "NONE" },
      }
    })

    -- التنقل بين الـ buffers
    vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true })
    vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true })
    vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { silent = true })
    -- its theming
    vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = "#c5c8c6", bg = "NONE" })
    vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = "#ffffff", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = "#969896", bg = "NONE" })
  end
}
