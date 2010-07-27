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

function! Comment() range
    execute a:firstline.','.a:lastline.'s/^/'.b:commentChar.'/'
endfunction

function! UnComment() range
    execute a:firstline.','.a:lastline.'s/^'.b:commentChar.' \?//'
endfunction

map ## :call Comment()<cr>
map !# :call UnComment()<cr>

map <C-T>n :tabnext<CR>
map <C-T>p :tabprev<CR>

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
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
"
" turn on tab-completion
" imap <Tab> <C-N>
" turn on SmartTabs
inoremap <tab> <c-r>=SmartTab()<cr>
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
" Text::Forge Specific Settings
"function! TForge()
"    " Text::Forge is a Perl module
"    call Perl()
"endfunction
"
function! Sql()
    let b:commentChar = "--"
endfunction
function! Vim()
    let b:commentChar = "\""
endfunction
" ------------------------------------------------------------------------------
" Functions for status bar.  ( Probably only works with newer version of VIM )
" ------------------------------------------------------------------------------
function! CurrSubName()
    let b:subname = ""
    let b:subrecurssion = 0

    " See if this is a Perl file
    let l:firstline = getline(1)

    if ( l:firstline =~ '#!.*perl' || l:firstline =~ '^package ' )
        call GetSubName(line("."))
    endif

    return b:subname
endfunction

function! GetSubName(line)
    let l:str = getline(a:line)

    if l:str =~ '^\s*sub\>'
        let l:str = substitute( l:str, ' *{.*', '', '' )
        let l:str = substitute( l:str, '^\s*sub *', ': ', '' )
        let b:subname = l:str
        return 1
    elseif ( l:str =~ '^}' || l:str =~ '^} *#' ) && b:subrecurssion >= 1
        return -1
    elseif a:line > 2
        let b:subrecurssion = b:subrecurssion + 1
        if b:subrecurssion < 190
            call GetSubName(a:line - 1)
        else
            let b:subname = ': <too deep>'
            return -1
        endif
    else
        return -1
    endif
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
" set a safe default for commentChar
let b:commentChar='# '
"
" look for Perl Test::Harness documents
autocmd BufNewFile,Bufread *.t set filetype=perl
"
" look for TextForge documents
autocmd BufNewFile,Bufread *.tf set filetype=tforge
"
" look for JSP Fragments
autocmd BufNewFile,Bufread *.jspf set filetype=jsp
"
" set It's All Text comment leader (for Bugzilla)
autocmd BufNewFile,Bufread */itsalltext/* let b:commentChar='> '
"
" call appropriate language-specific function based on file type
"autocmd FileType perl   call Perl()
"autocmd FileType tforge call TForge()
autocmd FileType java   call Java()
autocmd FileType sql    call Sql()
autocmd FileType vim    call Vim()
