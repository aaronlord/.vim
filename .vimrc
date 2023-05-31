call plug#begin('~/.vim/plugged')

" Plug 'adalessa/laravel.nvim', {'for': 'php'}
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'github/copilot.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'machakann/vim-highlightedyank'
Plug 'mhinz/vim-startify'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate' }
Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --ignore-platform-reqs --no-dev -o'}
Plug 'romgrk/barbar.nvim'
Plug 'terrastruct/d2-vim'
Plug 'terryma/vim-multiple-cursors'
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
" source ~/.vim/includes/plugins/laravel.lua
source ~/.vim/includes/plugins/lspconfig.lua
source ~/.vim/includes/plugins/lualine.lua
source ~/.vim/includes/plugins/startify.vim
source ~/.vim/includes/plugins/telescope.lua
source ~/.vim/includes/plugins/tree.lua

if !empty(glob('~/.vim/includes/extra.vim'))
    source ~/.vim/includes/extra.vim
endif
