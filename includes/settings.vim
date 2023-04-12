set nocompatible                    " iMproved
set t_Co=256                        " 256 Colors
set mousehide                       " Hide cursor while typing
scriptencoding utf-8
set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set virtualedit=onemore             " Allow for cursor beyond last character
set history=1000                    " Store a ton of history (default is 20)
set hidden                          " Allow buffer switching without saving
set showmode                        " Always show what mode we're currently editing in
set nowrap                          " Don't wrap lines
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
set wildmode=list:longest,full
set guicursor=                      " Don't change the cursor
set mouse=

" Highlight annoying whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>

" Ignore common useless files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/vendor/*,*/storage/*,*/cache/*,*/node_modules/*,*/bower_components/*,*/.undodir/*,*/.phpunit.cache/*

let g:clipboard = {
  \   'name': 'WslClipboard',
  \   'copy': {
  \      '+': 'clip.exe',
  \      '*': 'clip.exe',
  \    },
  \   'paste': {
  \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  \   },
  \   'cache_enabled': 0,
  \ }
