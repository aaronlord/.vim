set nocompatible
set t_Co=256

colorscheme xoria256
syntax      on

filetype    off
filetype    plugin indent on

set mouse=a                     " Enable mouse, a=all
set mousehide                   " Hide cursor while typing
scriptencoding utf-8

set shortmess+=filmnrxoOtT      " Abbrev. of messages (avoids 'hit enter')
set virtualedit=onemore         " Allow for cursor beyond last character
set history=1000                " Store a ton of history (default is 20)
set hidden                      " Allow buffer switching without saving
set showmode                    " Always show what mode we're currently editing in
set nowrap                      " Don't wrap lines
set tabstop=4                   " A tab is four spaces
set smarttab
set tags=tags
set softtabstop=4               " <BS> 'space-tabs'
set expandtab                   " Expand tabs by default
set shiftwidth=4                " Number of spaces to use for autoindenting
set shiftround                  " Use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " Allow backspacing over everything in insert mode
set autoindent                  " Always set autoindenting on
set copyindent                  " Copy the previous indentation on autoindenting
set pastetoggle=<F8>            " Pastetoggle (sane indentation on pastes)
set number                      " Always show line numbers
set hlsearch                    " Highlight search results
set ignorecase                  " Ignore case when searching
set smartcase                   " Ignore case if search pattern is all lowercase,
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then 
                                " longest common part, then all.
set visualbell                  " Don't beep
set noerrorbells                " Don't beep
set autowrite                   " Save on buffer switch
set timeoutlen=500              " Reduce the delay after hiting the leader key
set lazyredraw                  " Don't redraw while executing macros, performace++
set autoread                    " Autoread when file changes from outside
set cursorline                  " Highlight current line

highlight clear SignColumn      " SignColumn should match background for
                                " things like vim-gitgutter

highlight clear LineNr          " Current line number row will have
                                " same background color in relative
                                " mode.

" Highlight problematic whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>

" Display a 80 char line and color
set colorcolumn=80
highlight ColorColumn ctermbg=236

" Swap files out of the project root
set backupdir=~/.vim/backup/
set directory=~/.vim/swap/

" Remove search results
command! H let @/=""

" Extra key combinations /w a leader key
let mapleader = ","
let g:mapleader = ","

" Fast saves
nmap <leader>w :w!<cr>

" Easy escaping to normal model
imap jj <esc>

" Yank from the cursor to the end of the line, to be consistent with C and D
nnoremap Y y$

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Down is really the next line
nnoremap j gj
nnoremap k gk

" Bubble sort single lines
nmap <C-Up>   ddkP
nmap <C-Down> ddp

" Buffers jumping & deleting
nnoremap gb :ls<CR>:b<Space>
nnoremap gd :ls<CR>:bd<Space>

" Easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Easier tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-l> :tabnext<CR>

" PHPUnit
nmap <leader>ta :!phpunit<cr>
nmap <leader>tt :!phpunit %:p<cr>

" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle "scrooloose/nerdtree"
Bundle "kien/ctrlp.vim"
Bundle "Lokaltog/vim-powerline"
Bundle "tpope/vim-fugitive"
Bundle "airblade/vim-gitgutter"
Bundle "mileszs/ack.vim"
Bundle "Lokaltog/vim-easymotion"
Bundle "Townk/vim-autoclose"
Bundle "terryma/vim-multiple-cursors"
Bundle "spf13/PIV"
Bundle "joonty/vim-phpqa"
Bundle "ervandew/supertab"
Bundle "majutsushi/tagbar"
Bundle "scrooloose/nerdcommenter"
Bundle "tpope/vim-surround"
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle "honza/vim-snippets"

" NerdTREE
map <C-k><C-b> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.svn', '\.bzr', '\.DS_Store', '\.sass-cache']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

" ctrlp
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.hg$\|\.svn$',
    \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

" Powerline
let g:Powerline_symbols = 'fancy'
set laststatus=2                  " Always show the statusline
set encoding=utf-8                " Necessary to show Unicode glyphs
set noshowmode                    " Hide the default mode text
set showcmd                       " Show (partial) command in the status line

" PIV
let g:DisableAutoPHPFolding=1

" phpqa
let g:phpqa_codesniffer_args="--standard=/Users/aaron/phpcs.xml -s"

" Tagbar
nmap <C-k><C-t> :TagbarToggle<CR>
