imap <silent><script><expr> ` copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

imap <silent> <A-`> <Plug>(copilot-next)
imap <silent> <C-`> <Plug>(copilot-previous)
