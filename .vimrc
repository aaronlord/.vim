call plug#begin('~/.vim/plugged')

Plug 'L3MON4D3/LuaSnip' " LSP
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}
Plug 'airblade/vim-gitgutter'
Plug 'github/copilot.vim'
Plug 'hrsh7th/cmp-nvim-lsp' " LSP
Plug 'hrsh7th/nvim-cmp' " LSP
Plug 'itchyny/vim-gitbranch'
Plug 'machakann/vim-highlightedyank'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'neovim/nvim-lspconfig' " LSP
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --ignore-platform-reqs --no-dev -o'}
Plug 'romgrk/barbar.nvim'
Plug 'tpope/vim-fugitive'
Plug 'williamboman/mason-lspconfig.nvim' " LSP
Plug 'williamboman/mason.nvim', " LSP
Plug 'yggdroot/indentline'

call plug#end()

source ~/.vim/includes/commands.vim
source ~/.vim/includes/keybinds.vim
source ~/.vim/includes/paths.vim
source ~/.vim/includes/settings.vim
source ~/.vim/includes/syntax.vim

source ~/.vim/includes/plugins/barbar.lua
source ~/.vim/includes/plugins/copilot.vim
source ~/.vim/includes/plugins/gitgutter.vim
source ~/.vim/includes/plugins/indentline.vim
source ~/.vim/includes/plugins/lualine.lua
source ~/.vim/includes/plugins/lsp.lua
source ~/.vim/includes/plugins/startify.vim
source ~/.vim/includes/plugins/telescope.lua
source ~/.vim/includes/plugins/tree.lua
source ~/.vim/includes/plugins/treesitter.lua
source ~/.vim/includes/plugins/undotree.vim

if !empty(glob('~/.vim/includes/extra.vim'))
    source ~/.vim/includes/extra.vim
endif
