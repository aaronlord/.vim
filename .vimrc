" Neovim config ~/.config/nvim/init.vim redirects here.

"
" vim-plug
"
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

"
" Settings
"
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

" Highlight annoying whitespace
set list
set listchars=tab:.\ ,trail:.,nbsp:.,precedes:<,extends:>

" Ignore common useless files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/vendor/*,*/storage/*,*/cache/*,*/node_modules/*,*/bower_components/*,*/.undodir/*

" Swap files out of the project root
set backupdir=~/.config/nvim/backup/
set directory=~/.config/nvim/swap/

syntax on
" autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.blade.php set ft=html
autocmd BufNewFile,BufRead *.vue set ft=vue

let g:python3_host_prog="/usr/bin/python3"


"
" Keybinds
"

" <leader> = ,
let mapleader=","
let g:mapleader=","

" :H removes search results
command! H let @/=""

" Format JSON files
command! JSON %!python -m json.tool

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

nmap <Leader>r :.!python ~/.config/nvim/headwind.py<CR>

" <C-w><C-[h, l]> navigates to the previous and next tab
nmap <C-w><C-h> :tabprevious<CR>
nmap <C-w><C-l> :tabnext<CR>

"
" airline
"
let g:airline#extensions#whitespace#enabled=0
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#bufferline#enabled=1
let g:airline_powerline_fonts=1

"
" coc
"
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

let g:LanguageClient_serverCommands = {'vue': ['vls']}

"
" buffertagor
"
let g:buffergator_display_regime='bufname'
let g:buffergator_suppress_keymaps=1
let g:buffergator_split_size=40
nmap <leader>b :BuffergatorToggle<CR>

"
" ctrlp
"
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_match_window='bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=20
let g:ctrlp_show_hidden=1
let g:ctrlp_custom_ignore='\v[\/]\public$'

"
" NERDTree
"
map <C-k><C-b> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
let NERDTreeShowBookmarks=0
let NERDTreeIgnore=['\.pyc','\~$','\.swo$','\.swp$','\.git$','\.svn','\.idea$', '\.bzr','\.DS_Store','\.sass-cache','\.vagrant', '\.undodir']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let NERDTreeDirArrows=1
let NERDTreeWinSize=40

" Close vim if only NERDTree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Open NERDTree on empty startup
" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

" black, blue, green, yellow, cyan, white, magenta, red
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('xml', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('neon', 'yellow', 'none', 'yellow', 'none')
call NERDTreeHighlightFile('vue', '041', 'none', '041', 'none')
call NERDTreeHighlightFile('js', '226', 'none', '226', 'none')
call NERDTreeHighlightFile('php', '075', 'none', '075', 'none')
call NERDTreeHighlightFile('blade.php', '214', 'none', '214', 'none')
call NERDTreeHighlightFile('html', '214', 'none', '214', 'none')
call NERDTreeHighlightFile('css', '169', 'none', '169', 'none')

let g:indentLine_color_term = 238
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

"
" Workspace
"
let g:workspace_autosave = 0

"
" Pt
"
" let g:ptprg=$HOME."/Code/bin/pt --column"

"
" GitGutter
"
let g:gitgutter_map_keys = 0

"
" Git-Blame
"
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>


"
" Colors
"
colorscheme monokai
set colorcolumn=80,120
highlight clear SignColumn
