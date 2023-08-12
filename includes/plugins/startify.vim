" :mksession

function! s:gitFiles()
    let files = systemlist('git ls-files -om --exclude-standard 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

let g:startify_lists = [
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'dir',       'header': ['   Recents'] },
        \ { 'type': function('s:gitFiles'),  'header': ['   Git']},
        \ { 'type': 'commands',  'header': ['   Commands']       },
        \ ]

let g:startify_session_persistence = 1
let g:startify_change_to_vcs_root = 1

let g:startify_custom_header = startify#pad(split(system('figlet -f small $(basename $PWD)'), '\n'))
