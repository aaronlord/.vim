" Neovim config ~/.config/nvim/init.vim redirects here.

call plug#begin('~/.vim/plugged')

Plug 'zivyangll/git-blame.vim'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'machakann/vim-highlightedyank'
Plug 'nazo/pt.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'
Plug 'thaerkh/vim-workspace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'yggdroot/indentline'

call plug#end()

source includes/plugins/airline.vim
source includes/plugins/buffergator.vim
source includes/plugins/coc.vim
source includes/plugins/ctrlp.vim
source includes/plugins/gitblame.vim
source includes/plugins/gitgutter.vim
source includes/plugins/nerdtree.vim
source includes/plugins/pt.vim
source includes/plugins/workspace.vim

source includes/commands.vim
source includes/keybinds.vim
source includes/paths.vim
source includes/settings.vim
source includes/syntax.vim
