call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'github/copilot.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate' }
Plug 'romgrk/barbar.nvim'
Plug 'terryma/vim-multiple-cursors'
Plug 'thaerkh/vim-workspace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'yggdroot/indentline'
Plug 'zivyangll/git-blame.vim'

call plug#end()

source ~/.vim/includes/commands.vim
source ~/.vim/includes/keybinds.vim
source ~/.vim/includes/paths.vim
source ~/.vim/includes/settings.vim
source ~/.vim/includes/syntax.vim

source ~/.vim/includes/plugins/barbar.lua
source ~/.vim/includes/plugins/coc.vim
source ~/.vim/includes/plugins/copilot.vim
source ~/.vim/includes/plugins/gitblame.vim
source ~/.vim/includes/plugins/gitgutter.vim
source ~/.vim/includes/plugins/indentline.vim
source ~/.vim/includes/plugins/telescope.lua
source ~/.vim/includes/plugins/workspace.vim
source ~/.vim/includes/plugins/lualine.lua
source ~/.vim/includes/plugins/nvimtree.lua

if !empty(glob('~/.vim/includes/extra.vim'))
    source ~/.vim/includes/extra.vim
endif
