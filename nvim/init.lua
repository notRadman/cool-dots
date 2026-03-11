-- ========== Appearance ==========
vim.cmd('colorscheme unokai')     -- Nice default color theme
vim.opt.syntax = 'on'             -- Code syntax highlighting
vim.opt.number = true             -- Line numbers
vim.opt.relativenumber = true     -- Relative line numbers (easier for movement)
vim.opt.cursorline = true         -- Highlight current line
vim.opt.showmatch = true          -- Show matching brackets

-- ========== Indentation and Spacing ==========
vim.opt.tabstop = 4               -- Tab = 4 spaces
vim.opt.shiftwidth = 4            -- Auto-indent 4 spaces
vim.opt.expandtab = true          -- Convert tabs to spaces
vim.opt.autoindent = true         -- Automatic indentation
vim.opt.smartindent = true        -- Smart indentation based on code

-- ========== Folding ==========
vim.opt.foldmethod = 'indent'     -- Fold based on indentation
vim.opt.foldlevel = 99            -- Start with everything unfolded
vim.opt.foldlevelstart = 99       -- Open all folds when opening a file

-- ========== Search ==========
vim.opt.ignorecase = true         -- Ignore case in search
vim.opt.smartcase = true          -- If you type uppercase, become case-sensitive
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Instant search while typing
vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true })

-- ========== General Improvements ==========
vim.opt.mouse = 'a'               -- Enable mouse
vim.opt.clipboard = 'unnamedplus' -- Share clipboard with system
vim.opt.wrap = true               -- Wrap long lines
vim.opt.scrolloff = 8             -- Keep 8 lines visible when scrolling
vim.opt.signcolumn = 'yes'        -- Column for signs (git, errors)
vim.opt.updatetime = 300          -- Faster updates
vim.opt.encoding = 'utf-8'        -- UTF-8 support
vim.opt.fileencoding = 'utf-8'
vim.opt.termbidi = true           -- Bidirectional text support
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { silent = true })  -- better buffer thing
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { silent = true })
vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { silent = true })

-- ========== Status Bar ==========
vim.opt.laststatus = 0            -- Always show status bar
vim.opt.showcmd = true            -- Show commands while typing
vim.opt.ruler = true              -- Cursor position in corner

-- ========== Transparent background  ========== 
vim.cmd([[
  hi Normal guibg=NONE ctermbg=NONE
  hi NormalFloat guibg=NONE ctermbg=NONE
]])

-- ========== Window Resizing (Native Neovim) ==========
vim.keymap.set('n', '<Space>h', ':vertical resize -3<CR>', { desc = 'Resize narrower (left)', silent = true })
vim.keymap.set('n', '<Space>j', ':resize -3<CR>', { desc = 'Resize shorter (down)', silent = true })
vim.keymap.set('n', '<Space>k', ':resize +3<CR>', { desc = 'Resize taller (up)', silent = true })
vim.keymap.set('n', '<Space>l', ':vertical resize +3<CR>', { desc = 'Resize wider (right)', silent = true })

-- ========== Leader Key ==========
vim.g.mapleader = ','  -- (,) as leader key

-- ========== Window Navigation ==========
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
-- Leader (.) + regular vim moving things

-- ========== Load Plugins ==========
require('config.lazy')

-- ========== Auto-open file tree on startup ==========
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    require("nvim-tree.api").tree.open()
--  end
--})

-- ========== Close all plugins (tree + terminal) ==========
vim.keymap.set('n', '<leader>w', function()
  -- Close nvim-tree
  local nvim_tree_api = require('nvim-tree.api')
  if nvim_tree_api.tree.is_visible() then
    nvim_tree_api.tree.close()
  end
  
  -- Close all terminals
  vim.cmd('TermExec cmd="exit"')
end, { desc = 'Close all plugins' })
