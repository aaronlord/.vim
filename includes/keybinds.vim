let mapleader=" "
let g:mapleader=" "

" :w!! to sudo save
cmap w!! w !sudo tee > /dev/null %

" <leader>p paste without overwriting register
xnoremap <leader>p "_dP

" <leader>q to macro record
noremap <Leader>q q
noremap q <Nop>

" Yank to clipboard
vnoremap yc "+y

" >, < tabs in/out visual mode
vnoremap < <gv
vnoremap > >gv

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

" <C-w><C-[h, l]> navigates to the previous and next tab
nmap <C-w><C-h> :tabprevious<CR>
nmap <C-w><C-l> :tabnext<CR>
