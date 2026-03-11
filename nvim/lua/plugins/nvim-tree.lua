return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  
    -- ========== Keymaps inside NvimTree ==========
    local function on_attach(bufnr)
      local api = require('nvim-tree.api')
    
      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
    
      -- Default shortcuts
      api.config.mappings.default_on_attach(bufnr)
    
      -- Additional shortcuts
      vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD - Change root to node'))
      vim.keymap.set('n', 'U', api.tree.change_root_to_parent, opts('Up - Go to parent directory'))
      vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
    end
  
    require("nvim-tree").setup({
      -- ========== Appearance ==========
      view = {
        width = 25,
        side = "left",
        relativenumber = true,
      },
    
      -- ========== Icons ==========
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = true, 
            git = false,
          },
          glyphs = {
            folder = {
              arrow_closed = "▸",
              arrow_open = "▾",
            },
          },
        },
      },
    
      -- ========== Filters ==========
      filters = {
        dotfiles = false,
        custom = { "^.git$", "node_modules", ".cache" },
      },
    
      -- ========== Git Integration ==========
      git = {
        enable = true,
        ignore = false,
      },
    
      -- ========== Behaviour ==========
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
          },
        },
        change_dir = {
          enable = true,
          global = true,
        },
      },
    
      -- ========== Additional settings ==========
      update_focused_file = {
        enable = true,
        update_root = true,
      },
    
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
    
      -- ========== Change root automatically ==========
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_cwd = true,
    
      -- ========== Activate on_attach ==========
      on_attach = on_attach,
    })
  
    -- ========== Keymaps outside NvimTree ==========
    vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    vim.keymap.set("n", "<leader>o", "<CMD>NvimTreeFocus<CR>", { desc = "Focus file tree" })
    vim.keymap.set("n", "<leader>i", "<C-w>p", { desc = "Go back to previous window" })
    vim.keymap.set("n", "<leader>ff", "<CMD>NvimTreeFindFile<CR>", { desc = "Find current file in tree" })
  
    -- ========== Changing the side (right/left) ==========
    local function toggle_tree_side()
      local view = require('nvim-tree.view')
      local api = require('nvim-tree.api')
    
      -- close the tree
      if view.is_visible() then
        api.tree.close()
      end
    
      -- change the current side
      local current_side = require('nvim-tree.view').View.side
      if current_side == 'left' then
        require('nvim-tree.view').View.side = 'right'
      else
        require('nvim-tree.view').View.side = 'left'
      end
    
      -- reopen it
      api.tree.open()
    end
  
    vim.keymap.set("n", "<leader>re", toggle_tree_side, { desc = "Toggle tree side (left/right)" })
  end
}
