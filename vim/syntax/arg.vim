syntax match Assertion /^\S.*$/
highlight link Assertion Statement

syntax region But start=/But\s.*$/ end=/\n\n/
highlight link But Error

syntax region Because start=/Because\s.*$/ end=/\n\n/
highlight link Because Constant

syntax match OddSpace /^\(\s\s\)*\s\S/
highlight OddSpace guibg=#ffbbbb guifg=white
