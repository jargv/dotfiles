"Options {{{1
set iskeyword+=-,@-@

"mappings {{{1
map <buffer> <F3> :exec "e ".expand('%:r').".js"<cr>

inoremap <expr> <buffer> <S-TAB> <SID>shift_tab()
func! <SID>shift_tab()
   if pumvisible() | return "" | else | return "\<S-Tab>" | endif
endfunc

inoremap <buffer> @ @
inoremap <buffer> : : 

inoremap <buffer> <expr> ; <sid>semicolon()
func! <sid>semicolon()
   let source = getline('.')
   if match(source, ':') != -1
      return ";"
   else
      return ": "
   endif
endfunc

inoremap <expr> <buffer> <Space> <SID>space()
func! <SID>space()
   return " "
endfunc

"change from inline {{{1
nnoremap <buffer> <F4> :call <SID>outlineCSS()<CR><CR>
func! <SID>outlineCSS()
  "replace foo:{ with .foo{
  s/^\v(\w*)\s*\:\s*\{/.\1 {/e

  "remove single qutoes from the value
  s/\v^(\s*\w*)\:\s*'([^']*)'(.*)/\1:\ \2\3/e

  "remove double qutoes from the value
  s/\v^(\s*\w*)\:\s*"([^"]*)"(.*)/\1:\ \2\3/e

  "remove backtick qutoes from the value
  s/\v^(\s*\w*)\:\s*`([^`]*)`(.*)/\1:\ \2\3/e

  "change `+ "px"` to just px
  s/\v\s*\+\s*["']px["'](.*)$/px\1/e

  "remove the trailing comma at the end of a block
  s/},/}/e

  "replace trailing comma at the end of a value
  s/,\s*$/;/e

  "camelCase to snake-case properties
  s/\v^(\s*)(\l*)(\u)(\l*):/\1\2-\l\3\4:/e
endfunc

" Autocomplete mappings {{{1
inoremap <expr> <buffer> <TAB> <SID>tab()
func! <SID>tab()
   if pumvisible() | return "" | endif

   let source = getline('.')
   if source =~ '^\s*\%' . getpos('.')[2] . 'c'
      return "\<TAB>"
   else
      return ""
   endif
endfunc

"Autocompletion {{{1
setlocal completeopt=menu,longest,preview
let s:spec = {} "defined below
func! MyCompleteCSS(findstart, base)
   let line = getline('.')
   let property = line =~ ':'
   if (a:findstart)
      if property
         return match(line, "\S*$")
      else
         return match(line, '\S')
      endif
   else
      if property
         let value = line[0:col('.')-1]
         let value = get(matchlist(value, ':\s*\(.*\)$'), 1)
         let value = substitute(value, '\s\+', ' ', 'g')
         let value = substitute(value, '\S', '', 'g')
         let nSpaces = strlen(value)
         "call inputdialog(nSpaces)
         return get(get(s:spec, get(matchlist(line, '\(\S\+\):'), 1), []), nSpaces, [])
      else
         return filter(sort(keys(s:spec)), 'v:val =~ "^".a:base')
      endif
   endif
endfunc
set omnifunc=MyCompleteCSS

inoremap <buffer> { {}O

let s:colors = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow']
let s:borderStyle = [ 'none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset']
let s:backgroundColors = s:colors + ['transparent']
let s:length = ['0', '1px', '1em', '1ex', '1in', '1cm', '1mm', '1pt', '1pc']
let s:borderWidth = ['thin', 'medium', 'thick'] + s:length
let s:lengthOrAuto = ['auto'] + s:length
let s:repeat = ["repeat", "repeat-x",  "repeat-y", "no-repeat"]
let s:url = ['url(', 'none']
let s:percentage = ["1%"]
let s:auto = ["auto"]
let s:backgroundPosition = [s:percentage + s:length + ['left', 'center', 'right'], s:percentage + s:length + ['top', 'center', 'bottom']]
let s:font = ["serif", "sans-serif", "cursive", "fantasy", "monospace"]
let s:fontStyle = ['normal', 'italic', 'oblique']
let s:fontVariant = ['normal', 'small-caps']
let s:absoluteSize = ["xx-small", "x-small", "small", "medium", "large", "x-large", "xx-large"]
let s:relativeSize = ['larger', 'smaller']

let s:flexDirection = ['row', 'row-reverse', 'column', 'column-reverse']
let s:flexWrap = ['nowrap', 'wrap', 'wrap-reverse']

let s:spec = {
      \'align-content': [['flex-start', 'flex-end', 'center', 'stretch', 'space-between', 'space-around']],
      \'align-items': [['flex-start', 'flex-end', 'center', 'stretch', 'baseline']],
      \'align-self': [['auto', 'flex-start', 'flex-end', 'center', 'baseline', 'stretch']],
      \'azimuth': [['<angle>', 'left-side', 'far-left', 'left', 'center-left', 'center', 'center-right', 'right', 'far-right', 'right-side', 'behind', 'leftwards', 'rightwards']],
      \'background': [s:backgroundColors, s:url, s:repeat, ['scroll', 'fixed']] + s:backgroundPosition,
      \'background-attachment': [['scroll', 'fixed']],
      \'background-color': [s:backgroundColors],
      \'background-image': [s:url],
      \'background-position': s:backgroundPosition,
      \'background-repeat': [s:repeat],
      \'border': [s:borderWidth, s:borderStyle, s:backgroundColors],
      \'border-bottom': [s:borderWidth, s:borderStyle, s:colors],
      \'border-bottom-color':[s:backgroundColors],
      \'border-bottom-style':[s:borderStyle],
      \'border-bottom-width':[s:borderWidth],
      \'border-collapse': [['collapse', 'separate']],
      \'border-color': [s:backgroundColors],
      \'border-left': [s:borderWidth, s:borderStyle, s:colors],
      \'border-left-color':[s:backgroundColors],
      \'border-left-style':[s:borderStyle],
      \'border-left-width':[s:borderWidth],
      \'border-right': [s:borderWidth, s:borderStyle, s:colors],
      \'border-right-color':[s:backgroundColors],
      \'border-right-style':[s:borderStyle],
      \'border-right-width':[s:borderWidth],
      \'border-spacing': [s:length, s:length],
      \'border-style': [s:borderStyle, s:borderStyle, s:borderStyle, s:borderStyle],
      \'border-top': [s:borderWidth, s:borderStyle, s:colors],
      \'border-top-color': [s:backgroundColors],
      \'border-top-style': [s:borderStyle],
      \'border-top-width': [s:borderWidth],
      \'border-width': [s:borderWidth, s:borderWidth, s:borderWidth, s:borderWidth],
      \'bottom': [s:length + s:percentage],
      \'caption-side': [['top', 'bottom']],
      \'clear': [['none', 'left', 'right', 'both']],
      \'clip': [['<shape>', 'auto']],
      \'color': [s:colors],
      \'content': [['normal', 'none', '""', 'url(', '<counter>', 'attr(', 'open-quote', 'close-quote', 'no-open-quote', 'no-close-quote']],
      \'counter-increment': [['<identifier> <integer>', 'none']],
      \'counter-reset': [['<identifier> <integer>', 'none']],
      \'cue': [['cue-before', 'cue-after' ]],
      \'cue-after': [s:url],
      \'cue-before': [s:url],
      \'cursor': [['url(', 'auto', 'crosshair', 'default', 'pointer', 'move', 'e-resize', 'ne-resize', 'nw-resize', 'n-resize', 'se-resize', 'sw-resize', 's-resize', 'w-resize', 'text', 'wait', 'help', 'progress', 'visual', 'interactive']],
      \'display': [['inline', 'block', 'flex', 'inline-flex', 'list-item', 'inline-block', 'table', 'inline-table', 'table-row-group', 'table-header-group', 'table-footer-group', 'table-row', 'table-column-group', 'table-column', 'table-cell', 'table-caption', 'none']],
      \'elevation': [['<angle>', 'below', 'level', 'above', 'higher', 'lower']],
      \'empty-cells': [['show', 'hide']],
      \'flex': [['none']],
      \'flex-basis': [s:length + s:percentage + s:auto],
      \'flex-direction': [s:flexDirection],
      \'flex-flow': [s:flexDirection, s:flexWrap],
      \'flex-grow': [['1', '2', '...']],
      \'flex-wrap': [s:flexWrap],
      \'float': [['left', 'right', 'none']],
      \'font': [s:fontStyle + ['caption', 'icon', 'menu', 'message-box', 'small-caption', 'status-bar'], s:fontVariant, s:length + s:percentage + s:absoluteSize + s:relativeSize, s:font, s:font, s:font, s:font, s:font, s:font, s:font, s:font],
      \'font-family': [s:font, s:font, s:font, s:font, s:font, s:font, s:font],
      \'font-shrink': [['1', '2', '...']],
      \'font-size': [[s:length + s:percentage + s:absoluteSize + s:relativeSize]],
      \'font-style': [s:fontStyle],
      \'font-variant': [s:fontVariant],
      \'font-weight': [['normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900']],
      \'height': [s:length + s:percentage + s:auto],
      \'justify-content': [['flex-start', 'flex-end', 'center', 'space-between', 'space-around']],
      \'left': [s:length + s:percentage + s:auto],
      \'letter-spacing': [['normal'] + s:length],
      \'line-height': [['normal'] + s:length],
      \'list-style': [[['disc', 'circle', 'square', 'decimal', 'decimal-leading-zero', 'lower-roman', 'upper-roman', 'lower-greek', 'lower-latin', 'upper-latin', 'armenian', 'georgian', 'lower-alpha', 'upper-alpha', 'none']], [['inside', 'outside']], [s:url]],
      \'list-style-image': [s:url],
      \'list-style-position': [['inside', 'outside']],
      \'list-style-type': [['disc', 'circle', 'square', 'decimal', 'decimal-leading-zero', 'lower-roman', 'upper-roman', 'lower-greek', 'lower-latin', 'upper-latin', 'armenian', 'georgian', 'lower-alpha', 'upper-alpha', 'none']],
      \'margin': [s:length + s:percentage + s:auto, s:length + s:percentage + s:auto, s:length + s:percentage + s:auto, s:length + s:percentage + s:auto],
      \'margin-bottom': [s:length + s:percentage + s:auto],
      \'margin-left': [s:length + s:percentage + s:auto],
      \'margin-right': [s:length + s:percentage + s:auto],
      \'margin-top': [s:length + s:percentage + s:auto],
      \'max-height': [['none'] + s:length + s:percentage],
      \'max-width': [['none'] + s:length + s:percentage],
      \'min-height': [s:length + s:percentage],
      \'min-width': [s:length + s:percentage],
      \'order': [['1', '2', "..."]],
      \'orphans': [['1', '2', "..."]],
      \'outline': [s:borderWidth, s:borderStyle, s:colors],
      \'outline-color': [s:colors],
      \'outline-style': [s:borderStyle],
      \'outline-width':[s:borderWidth],
      \'overflow': ['visible', 'hidden', 'scroll', 'auto'],
      \'padding': [s:length + s:percentage, s:length + s:percentage, s:length + s:percentage, s:length + s:percentage],
      \'padding-bottom': [s:length + s:percentage],
      \'padding-left': [s:length + s:percentage],
      \'padding-right': [s:length + s:percentage],
      \'padding-top': [s:length + s:percentage],
      \'page-break-after': [['auto', 'always', 'avoid', 'left', 'right']],
      \'page-break-inside': [['avoid', 'auto']],
      \'pause': [[]],
      \'pause-after': [['<time>'] + s:percentage],
      \'pause-before': [['<time>'] + s:percentage],
      \'pitch': [['<frequency>', 'x-low', 'low', 'medium', 'high', 'x-high']],
      \'pitch-range': [['<number>']],
      \'play-during': [[]],
      \'position': [['static', 'relative', 'absolute', 'fixed']],
      \'quotes': [['<string>', 'none']],
      \'richness': [['<number>']],
      \'right': [s:length + s:percentage + s:auto],
      \'speak': [['normal', 'none', 'spell-out']],
      \'speak-header': [['once', 'always']],
      \'speak-numeral': [['digits', 'continuous']],
      \'speak-punctuation': [['code', 'none']],
      \'speech-rate': [['<number>', 'x-slow', 'slow', 'medium', 'fast', 'x-fast', 'faster', 'slower']],
      \'stress': [['<number>']],
      \'table-layout': [['auto', 'fixed']],
      \'text-align': [['left', 'right', 'center', 'justify']],
      \'text-decoration': [['none', 'underline,', 'overline,', 'line-through', 'blink']],
      \'text-indent': [s:length + s:percentage],
      \'text-transform': [['capitalize', 'uppercase', 'lowercase', 'none']],
      \'top': [s:length + s:percentage + s:auto],
      \'unicode-bidi': [['normal', 'embed', 'bidi-override']],
      \'vertical-align': [['baseline', 'sub', 'super', 'top', 'text-top', 'middle', 'bottom', 'text-bottom'] + s:percentage + s:length],
      \'visibility': [['visible', 'hidden', 'collapse']],
      \'voice-family': [['<specific-voice>', '<generic-voice>', '<specific-voice>', '<generic-voice>' ]],
      \'volume': [['<number>', '<percentage>', 'silent', 'x-soft', 'soft', 'medium', 'loud', 'x-loud']],
      \'white-space': [['normal', 'pre', 'nowrap', 'pre-wrap', 'pre-line']],
      \'widows': [[1, 2, '...']],
      \'width': [s:length + s:percentage + s:auto],
      \'word-spacing': [['normal'] + s:length],
      \'z-index': [['auto', '1', '2', '...', '-10000']],
      \}

