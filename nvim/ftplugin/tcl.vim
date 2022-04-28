
nmap <buffer> <expr> <F6> ":w<CR> :!gnome-terminal -x 
         \tclsh ./".expand('%:t')."&<CR><CR>"

nmap <buffer> <S-F6> :w<CR>:!gnome-terminal -x ~/config/scripts/rapidDev tclsh % &<CR>
