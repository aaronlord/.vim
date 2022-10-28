" :H removes search results
command! H let @/=""

" Format JSON files
command! JSON %!python -m json.tool
