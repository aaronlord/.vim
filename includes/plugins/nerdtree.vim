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

