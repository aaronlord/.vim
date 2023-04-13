let g:copilot_no_tab_map = v:true

imap <silent><script><expr> <A-`> copilot#Accept("\<CR>")
imap <silent> <C-`> <Plug>(copilot-next)
