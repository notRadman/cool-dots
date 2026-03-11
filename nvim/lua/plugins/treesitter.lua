return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      -- Languages to install
      ensure_installed = {"python", "c", "dart", "bash", "racket", "cpp", "lua", "rust", "html", "javascript"},
    
      -- Auto-install missing parsers when entering buffer
      auto_install = true,
    
      -- Syntax highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    
      -- Auto-indentation
      indent = {
        enable = true,
      },
    
      -- Incremental selection
      incremental_selection = {
        enable = false,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    
      -- Text objects
      textobjects = {
        enable = false,
      },
    
      -- Code folding
      fold = {
        enable = false,
      },
    
      -- Rainbow parentheses
      rainbow = {
        enable = false,
        extended_mode = true,
        max_file_lines = nil,
      },
    })
  end
}
