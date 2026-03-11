return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 10, 
      open_mapping = nil,
      direction = 'horizontal',
      shade_terminals = true,
      persist_size = true,
    })
    vim.keymap.set('n', '<leader>t', '<CMD>ToggleTerm<CR>', { desc = 'Toggle terminal' })
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
  end
}
