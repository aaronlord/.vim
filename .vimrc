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

source ~/.vim/includes/commands.vim
source ~/.vim/includes/keybinds.vim
source ~/.vim/includes/paths.vim
source ~/.vim/includes/settings.vim
source ~/.vim/includes/syntax.vim

source ~/.vim/includes/plugins/airline.vim
source ~/.vim/includes/plugins/buffergator.vim
source ~/.vim/includes/plugins/coc.vim
source ~/.vim/includes/plugins/ctrlp.vim
source ~/.vim/includes/plugins/gitblame.vim
source ~/.vim/includes/plugins/gitgutter.vim
source ~/.vim/includes/plugins/nerdtree.vim
source ~/.vim/includes/plugins/pt.vim
source ~/.vim/includes/plugins/workspace.vim

if !empty(glob('~/.vim/includes/extra.vim'))
    source ~/.vim/includes/extra.vim
endif
