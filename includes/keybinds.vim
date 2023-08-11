" <leader> = ,
let mapleader=","
let g:mapleader=","

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
vnoremap Yc "*yy

" >, < tabs in/out visual mode
vnoremap < <gv
vnoremap > >gv

" j, k behave as expected
nnoremap j gj
nnoremap k gk

" Bubble sort lines
" <C-Up>,   <C-k><C-k> up
" <C-Down>, <C-j><C-j> down
nmap <C-k><C-k> ddkP
nmap <C-j><C-j> ddp
vmap <C-k><C-k> :m '<-2<CR>gv=gv
vmap <C-j><C-j> :m '>+1<CR>gv=gv

" <C-[h, j, k, l]> navigates to the [window left, down, up, right]
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <Leader>r :.!python ~/.config/nvim/headwind.py<CR>

" <C-w><C-[h, l]> navigates to the previous and next tab
nmap <C-w><C-h> :tabprevious<CR>
nmap <C-w><C-l> :tabnext<CR>
