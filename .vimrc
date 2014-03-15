set nocompatible                                                               " iMproved
set t_Co=256                                                                   " 256 Colors
filetype off                                                                   " Required

" ==============================================================================
" General settings

set mouse=a                                                                    " Enable mouse, a=all
set mousehide                                                                  " Hide cursor while typing
scriptencoding utf-8
set shortmess+=filmnrxoOtT                                                     " Abbrev. of messages (avoids 'hit enter')
set virtualedit=onemore                                                        " Allow for cursor beyond last character
set history=1000                                                               " Store a ton of history (default is 20)
set hidden                                                                     " Allow buffer switching without saving
set showmode                                                                   " Always show what mode we're currently editing in
set nowrap                                                                     " Don't wrap lines
set tabstop=4                                                                  " A tab is four spaces
set smarttab
set tags=tags
set softtabstop=4                                                              " <BS> 'space-tabs'
set expandtab                                                                  " Expand tabs by default
set shiftwidth=4                                                               " Number of spaces to use for autoindenting
set shiftround                                                                 " Use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start                                                 " Allow backspacing over everything in insert mode
set autoindent                                                                 " Always set autoindenting on
set copyindent                                                                 " Copy the previous indentation on autoindenting
set number                                                                     " Always show line numbers
set hlsearch                                                                   " Highlight search results
set ignorecase                                                                 " Ignore case when searching
set smartcase                                                                  " Ignore case if search pattern is all lowercase,
set wildmode=list:longest,full                                                 " Command <Tab> completion, list matches, then longest common part, then all.
set visualbell                                                                 " Don't beep
set noerrorbells                                                               " Don't beep
set autowrite                                                                  " Save on buffer switch
set timeoutlen=500                                                             " Reduce the delay after hiting the leader key
set lazyredraw                                                                 " Don't redraw while executing macros, performace++
set autoread                                                                   " Autoread when file changes from outside
set cursorline                                                                 " Highlight current line
set laststatus=2                                                               " Always show the statusline
set noshowmode                                                                 " Hide the default mode text
set showcmd                                                                    " Show (partial) command in the status line

" Ignore common useless files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/vendor/*,*/storage/*,*/cache/*,*/node_modules/*

" Highlight problematic whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>

" Swap files out of the project root
set backupdir=~/.vim/backup/
set directory=~/.vim/swap/

" Remove search results with :H
command! H let @/=""

" Extra key combinations /w a leader key
let mapleader = ","
let g:mapleader = ","

" Fast saves
nmap <leader>w :w!<cr>

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

" PHPUnit
nmap <leader>ta :!clear && phpunit<cr>
nmap <leader>tt :!clear && phpunit %:p<cr>

" Tig
nmap <leader>g :!clear && tig<cr>

" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle "mileszs/ack.vim"
Bundle "johnhamelink/blade.vim"
Bundle "kien/ctrlp.vim"
Bundle "scrooloose/nerdtree"
Bundle "ervandew/supertab"
Bundle "Townk/vim-autoclose"
Bundle "jeetsukumaran/vim-buffergator"
Bundle "kchmck/vim-coffee-script"
Bundle "plasticboy/vim-markdown"
Bundle "Lokaltog/vim-easymotion"
Bundle "tpope/vim-fugitive"
Bundle "terryma/vim-multiple-cursors"
Bundle "Lokaltog/vim-powerline"
" Snippets
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle "honza/vim-snippets"

colorscheme xoria256
syntax on
filetype plugin indent on                                                      " required!
autocmd BufRead,BufNewFile *.blade.php  set filetype=blade


" Display a 80 char line and color
set colorcolumn=80
highlight ColorColumn ctermbg=236

" Buffergator
let g:buffergator_suppress_keymaps=1
nmap <leader>b :BuffergatorToggle<CR>

" NerdTREE
map <C-k><C-b> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
let NERDTreeShowBookmarks=0
let NERDTreeIgnore=['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git$', '\.svn', '\.bzr', '\.DS_Store', '\.sass-cache']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let NERDTreeDirArrows=1
let NERDTreeWinSize=35

" ctrlp
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_match_window='bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=20

" Powerline
let g:Powerline_symbols = 'fancy'

" Markdown
let g:vim_markdown_folding_disabled=1
