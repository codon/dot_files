set exrc
set autoindent
set ignorecase
set shiftwidth=4
set tabstop=4
set showmode
set cindent
set expandtab
set showmatch
set ruler
set showcmd
set nohlsearch
set viminfo=
set backspace=indent,eol,start
set mouse=
set listchars=tab:\|-,trail:-
set list
set hidden
set modeline
set modelines=5
" Diff options:
" - use filler chars for deleted lines
" - always use vertical splits (unless stated explicitly otherwise)
" - ignore whitespace
set diffopt=filler,vertical,iwhite
set comments=
"
" turn on syntax highlighting if using a color terminal
if &t_Co > 1
    syntax on
    colorscheme prairie_wind
endif
"
" remap <F1> (stupid help) to <Esc> (Ahhh) in all modes
map  <F1> <Esc>
imap <F1> <Esc>
nmap <F1> <Esc>
omap <F1> <Esc>
vmap <F1> <Esc>

" highlight trailing whitespace and spaces before a tab
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t\( \+\ze\)\?\|[^\t]\zs\t\+/

" strip trailing whitespace on file open, file save
autocmd BufRead,BufWritePre * call StripWhitespace()

function! StripWhitespace()
    if (&modifiable)
        exe "normal mz"
        %s/\s\+$//ge
        exe "normal `z"
    endif
endfunction

function! Comment() range
    execute a:firstline.','.a:lastline.'s/^/'.b:commentChar.'/'
endfunction

function! UnComment() range
    try
        execute a:firstline.','.a:lastline.'s/^\(\s*\)'.b:commentChar.'\( \?\)\@=/\1/'
    catch /E486:/
    endtry
endfunction

map ## :call Comment()<cr>
map !# :call UnComment()<cr>

map <C-T>n :tabnext<CR>
map <C-T>p :tabprev<CR>

function! AlignAssignments() range
    "Patterns needed to locate assignment operators...
    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'

" I'm making this a range operator. No magicks.
"    "Locate block of code to be considered (same indentation, no blanks)
"    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
"    let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
"    let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
"    if lastline < 0
"        let lastline = line('$')
"    endif

    "Find the column at which the operators should be aligned...
    let max_align_col = 0
    let max_op_width  = 0
    for linetext in getline(a:firstline, a:lastline)
        "Does this line have an assignment in it?
        let left_width = match(linetext, '\s*' . ASSIGN_OP)

        "If so, track the maximal assignment column and operator width...
        if left_width >= 0
            let max_align_col = max([max_align_col, left_width])

            let op_width      = strlen(matchstr(linetext, ASSIGN_OP))
            let max_op_width  = max([max_op_width, op_width+1])
         endif
    endfor

    "Code needed to reformat lines so as to align operators...
    let FORMATTER = '\=printf("%-*s%*s", max_align_col, submatch(1), max_op_width,  submatch(2))'

    " Reformat lines with operators aligned in the appropriate column...
    for linenum in range(a:firstline, a:lastline)
        let oldline = getline(linenum)
        let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
        call setline(linenum, newline)
    endfor
endfunction

vmap <silent> <Leader>==  :call AlignAssignments()<CR>

function! SplitConflict ()
    let l:bufferFileType = &filetype "get current filetype
    vnew
    read#
    0d
    let &filetype = l:bufferFileType "set filetype in new buffer to filetype of the old buffer
    " run deletions in the Left window
    call DeleteLeft()
    wincmd w
    " repeat deletions but in the opposite direction
    call DeleteRight()
    " turn on diff mode for this window
    diffthis
    "switch to the other window
    wincmd p
    "and turn on diffs there
    diffthis
endfunction

function! DeleteLeft()
    silent g/^=======/.;/^>>>>>>>/d
    silent g/^<<<<<<</d
    set nomod
    normal gg
endfunction

function! DeleteRight()
    silent g/^<<<<<<</.;/^=======/d
    silent g/^>>>>>>>/d
    set nomod
    normal gg
endfunction

" Move between screens with Ctrl+arrow keys
map <Esc>Oa <C-W><Up>
map <Esc>Ob <C-W><Down>
map <Esc>Oc <C-W><Right>
map <Esc>Od <C-W><Left>
map <Esc>[A <C-W><Up>
map <Esc>[B <C-W><Down>
map <Esc>[C <C-W><Right>
map <Esc>[D <C-W><Left>
map <Esc>O5A <C-W><Up>
map <Esc>O5B <C-W><Down>
map <Esc>O5C <C-W><Right>
map <Esc>O5D <C-W><Left>
"
" SmartTab wrapper
function! SmartTab()
    let col = col('.')
    if !col || getline('.') =~ '^\s\{'.col.'\}' " we have no column or the line is all whitespace in front of the cursor
        " [buffer,line,col,off] = getpos('.')
        let pos = getpos('.')
        let pos[2] += &sw
        >
        " setpos('.',[buffer,line,col,off])
        call setpos('.',pos)
        return ""
    elseif getline('.')[col - 2] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

" SmartUnTab wrapper
function! SmartUnTab()
    let col = col('.')
    if !col || getline('.') =~ '^\s\{'.col.'\}' " we have no column or the line is all whitespace in front of the cursor
        " [buffer,line,col,off] = getpos('.')
        let pos = getpos('.')
        let pos[2] -= &sw
        <
        " setpos('.',[buffer,line,col,off])
        call setpos('.',pos)
        return ""
    elseif getline('.')[col - 2] !~ '\k'
        return "\<c-o>".&sw."X"
    else
        return "\<c-n>"
    endif
endfunction
"
" turn on tab-completion
" imap <Tab> <C-N>
" turn on SmartTabs
inoremap <Tab>   <c-r>=SmartTab()<cr>
inoremap <S-Tab> <c-r>=SmartUnTab()<cr>
inoremap <Esc>[Z <c-r>=SmartUnTab()<cr>
"
" Set up color swap function
function! Swapcolor()
    if exists("b:syntax_on")
        syntax off
    else
        if     &background == 'light'
            set background=dark
        elseif &background == 'dark'
            set background=light
        endif
        syntax on
        colorscheme prairie_wind
    endif
endfunction
"
" SQL Specific Settings
function! Sql()
    let b:commentChar = "--"
endfunction
"
" Java Specific Settings
function! Java()
    set cinkeys&
    set cinkeys-=0#
    set cinwords&
    set cinoptions&
    set cinoptions+=+2s,(0,u0
    set cindent
    let b:commentChar = "//"
    "
    " compile current file (best for small projects
    map !! :!javac -d classes -classpath classes %<CR>
    " convinience abbreviations
    ab print System.out.println
    ab printe System.err.println
endfunction
"
function! Sql()
    let b:commentChar = "--"
endfunction
function! Vim()
    let b:commentChar = "\""
endfunction
"
" Convinience function key maps
set pastetoggle=<F2> " not redundant
map <F2> :set paste!<CR>
map <F3> :set number!<CR>
map <F4> :set wrap!<CR>
map <F5> :set list!<CR>
map <F8> :call Swapcolor()<CR>
"
" Map <Home> and <End> on M$ keyboard to do useful home/end function
imap <Esc>[H <C-O>0
imap <Esc>[F <C-O>$
nmap <Esc>[H      0
nmap <Esc>[F      $

"
" set a safe default for commentChar
let b:commentChar=''
"
" look for JSP Fragments
autocmd BufNewFile,Bufread *.jspf set filetype=jsp
"
" set It's All Text comment leader (for Bugzilla)
autocmd BufNewFile,Bufread */itsalltext/* let b:commentChar='> '
"
" call appropriate language-specific function based on file type
autocmd FileType java   call Java()
autocmd FileType sql    call Sql()
autocmd FileType vim    call Vim()
