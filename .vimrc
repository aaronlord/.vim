" Skip initialization for vim-tiny or vim-small.
if 0 | endif

" NeoBundle required:
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

" General settings
set nocompatible                    " iMproved
set t_Co=256                        " 256 Colors
set mousehide                       " Hide cursor while typing
scriptencoding utf-8
set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set virtualedit=onemore             " Allow for cursor beyond last character
set history=1000                    " Store a ton of history (default is 20)
set hidden                          " Allow buffer switching without saving
set showmode                        " Always show what mode we're currently editing in
"set nowrap                          " Don't wrap lines
set tabstop=4                       " A tab is four spaces
set smarttab
set tags=tags
set softtabstop=4                   " <BS> 'space-tabs'
set expandtab                       " Expand tabs by default
set shiftwidth=4                    " Number of spaces to use for autoindenting
set shiftround                      " Use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start      " Allow backspacing over everything in insert mode
set autoindent                      " Always set autoindenting on
set copyindent                      " Copy the previous indentation on autoindenting
set number                          " Always show line numbers
set hlsearch                        " Highlight search results
set ignorecase                      " Ignore case when searching
set smartcase                       " Ignore case if search pattern is all lowercase,
set visualbell                      " Don't beep
set noerrorbells                    " More don't beep
set autowrite                       " Save on buffer switch
set timeoutlen=500                  " Reduce the delay after hiting the leader key
set lazyredraw                      " Don't redraw while executing macros, performace++
set autoread                        " Autoread when file changes from outside
set cursorline                      " Highlight current line
set laststatus=2                    " Always show the statusline
set noshowmode                      " Hide the default mode text
set showcmd                         " Show (partial) command in the status line

" Command <Tab> completion, list matches, then longest common part, then all.
set wildmode=list:longest,full  

" Ignore common useless files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/vendor/*,*/storage/*,*/cache/*,*/node_modules/*,*/bower_components/*

" Highlight problematic whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>

" Swap files out of the project root
set backupdir=~/.vim/backup/
set directory=~/.vim/swap/

" Remove search results with :H
command! H let @/=""

" Extra key combinations /w a leader key
let mapleader=","
let g:mapleader=","

" Save quickly, save sudo
nmap <leader>w :w!<cr>
cmap w!! w !sudo tee > /dev/null %

" Easy escaping to normal model
imap jj <esc>

" Delete to end of word in insert mode
imap <C-e> <C-o>dw

" Yank from the cursor to the end of the line, to be consistent with C and D
nnoremap Y y$

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Down is really the next line
nnoremap j gj
nnoremap k gk

" Bubble sort single lines
nmap <C-Up>     ddkP
nmap <C-k><C-k> ddkP
nmap <C-Down>   ddp
nmap <C-j><C-j> ddp

" Easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Easier tab navigation
nmap <C-w><C-h> :tabprevious<CR>
nmap <C-w><C-l> :tabnext<CR>

" Change the default :Explore style
let g:netrw_liststyle=3

" Theme
colorscheme tomorrow-night
syntax on
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.blade.php set ft=html

" 80 character line
set colorcolumn=80
highlight ColorColumn ctermbg=236

" PHPUnit
nmap <leader>ta :!clear && phpunit<cr>
nmap <leader>tt :!clear && phpunit %:p<cr>

" Format json
command! JSON %!python -m json.tool

" NeoBundle required:
call neobundle#end()
filetype plugin indent on
NeoBundleCheck
