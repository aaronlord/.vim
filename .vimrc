" Skip initialization for vim-tiny or vim-small.
if 0 | endif


" =============================================================================
" NEOBUNDLE REQUIRED
" =============================================================================

set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'bling/vim-airline'
NeoBundle 'jeetsukumaran/vim-buffergator'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'posva/vim-vue'
NeoBundle 'beanworks/vim-phpfmt'


" =============================================================================
" GENERAL
" =============================================================================

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
set wildmode=list:longest,full      " Wild boys, wild boys, wild boys, dun dun dun dun, wild boys
set completeopt-=preview            " Disable that annoying af scratch window

" Ignore common useless files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/vendor/*,*/storage/*,*/cache/*,*/node_modules/*,*/bower_components/*

" Swap files out of the project root
set backupdir=~/.vim/backup/
set directory=~/.vim/swap/


" =============================================================================
" STYLE
" =============================================================================

" Syntax
syntax on
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.blade.php set ft=html
autocmd BufNewFile,BufRead *.vue set ft=vue

" Highlight annoying whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>


" =============================================================================
" CUSTOM MAPPINGS
" =============================================================================

" <leader> = ,
let mapleader=","
let g:mapleader=","

" :H removes search results
command! H let @/=""

" <leader>w to save, :w!! to sudo save
nmap <leader>w :w!<cr>
cmap w!! w !sudo tee > /dev/null %

" <leader>q to macro record
noremap <Leader>q q
noremap q <Nop>

" jj escapes insert mode
imap jj <esc>

" Y yanks to the end of the line
nnoremap Y y$

" >, < tabs in/out visual mode
vnoremap < <gv
vnoremap > >gv

" j, k behave as expected
nnoremap j gj
nnoremap k gk

" Bubble sort lines
" <C-Up>,   <C-k><C-k> up
" <C-Down>, <C-j><C-j> down
nmap <C-Up>     ddkP
nmap <C-k><C-k> ddkP
nmap <C-Down>   ddp
nmap <C-j><C-j> ddp

" <C-[h, j, k, l]> navigates to the [window left, down, up, right]
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" <C-w><C-[h, l]> navigates to the previous and next tab
nmap <C-w><C-h> :tabprevious<CR>
nmap <C-w><C-l> :tabnext<CR>

" PHPUnit
nmap <leader>ta :!clear && phpunit<cr>                      " Run all tests
nmap <leader>tt :!clear && phpunit %:p<cr>                  " Run this test

" :JSON formats this json file
command! JSON %!python -m json.tool


" =============================================================================
" AIRLINE
" =============================================================================

let g:airline#extensions#whitespace#enabled=0
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#bufferline#enabled=1
let g:airline_powerline_fonts=1


" =============================================================================
" Buffergator
" =============================================================================

let g:buffergator_suppress_keymaps=1
nmap <leader>b :BuffergatorToggle<CR>


" =============================================================================
" NerdTREE
" =============================================================================

map <C-k><C-b> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
let NERDTreeShowBookmarks=0
let NERDTreeIgnore=['\.pyc','\~$','\.swo$','\.swp$','\.git$','\.svn','\.idea$',
    \ '\.bzr','\.DS_Store','\.sass-cache','\.vagrant']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let NERDTreeDirArrows=1
let NERDTreeWinSize=40


" =============================================================================
" Ctrl-P
" =============================================================================

let g:ctrlp_working_path_mode='ra'
let g:ctrlp_match_window='bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=20


" =============================================================================
" NEOCOMPLETE
" =============================================================================

let g:acp_enableAtStartup=0                                 " Disable AutoComplPop.
let g:neocomplete#enable_at_startup=1                       " Use neocomplete.
let g:neocomplete#enable_smart_case=1                       " Use smartcase.
let g:neocomplete#sources#syntax#min_keyword_length=3       " Set minimum syntax keyword length.
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionaries.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
\ }

" Define keyword pattern
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" <C-g> Undos completion
inoremap <expr><C-g>     neocomplete#undo_completion()

" <CR> performs the completion
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction

" <TAB> selects the next item
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" <BS> closes popup and delete backword char.
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'


" =============================================================================
" NEOBUNDLE REQUIRED
" =============================================================================

call neobundle#end()
filetype plugin indent on
NeoBundleCheck

" Theme & character limit line
colorscheme tomorrow-night
set colorcolumn=80,120
highlight ColorColumn ctermbg=236


