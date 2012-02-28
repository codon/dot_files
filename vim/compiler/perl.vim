" Vim Compiler File
" Compiler:     Perl syntax checks (perl -Wc)
if exists("current_compiler")
    finish
endif
let current_compiler = "perl.vim"

let s:debug = 0       " toggle debugging messages

function! Debug(string)
    if s:debug
        let l:date = system('perl -MTime::HiRes -e "print join q{.}, Time::HiRes::gettimeofday()"')
        echo '['.l:date.'] debug: '.a:string
    endif
endfunction

function! s:Findlib_path(haystack, needle)
    call Debug( 'find '.a:haystack.' -type d -name '.a:needle )

    try
        let found_lib = finddir(a:needle,a:haystack)
        if strlen( found_lib ) != 0
            call Debug( 'found_lib ['.found_lib.']' )
            return '\ -I'.found_lib
        else
            call Debug( 'did not find '.a:needle.' in '.a:haystack )
        endif
    catch /^Vim\%((\a\+)\)\=:E486/ " pattern not found
        " no match; do nothing
    endtry

    return ''
endfunction

function! s:Findlib_file(haystack, needle)
    call Debug( 'find '.a:haystack.' -type d -name '.a:needle )

    try
        let matches = []
        let paths = findfile(a:needle, a:haystack, -1) " -1 here means 'get all'
        let lib_includes = ''
        for path in paths
            call Debug( 'looking at '.path )
            " make sure this DBI matches our Perl version
            if path =~ s:perl_version
                call Debug( path.' matches '.s:perl_version )
                " strip out extraneous path information
                let dbi_lib = substitute(dbi,'\(perl/s:lib\)/.*','\1','')
                " check to see if we have seen this path yet
                if -1 == match(matches,dbi_lib)
                    " add it to our paths to include
                    let lib_includes .= '\ -I'.dbi_lib
                    " and add it to our list of items seen
                    let matches = matches + [dbi_lib]
                else
                    " skip this; we've aleardy seen it
                endif
            endif
        endfor
    catch /^Vim\%((\a\+)\)\=:E486/ " pattern not found
        " no match; do nothing
    endtry

    return lib_includes
endfunction
" let's try to get the perl specified in the shebang line; if that does not exist, we fall back to $PATH
let s:perl= getline(1)
if s:perl =~ '^#!'
    let s:perl = substitute( s:perl,'#!\s*','','' ) " '\' needs to be escaped to get an effective \ in the pattern
    let s:perl = substitute( s:perl,' ','\\ ','g' )
elseif s:perl =~ '^\s*package\s\+\I\+'
    try
        let s:perl = system('which perl')
        let s:perl = substitute(s:perl,"\n",'','')
    catch /Pattern not found/
        let s:perl = 'perl'
    endtry
else
    let s:perl = 'perl'
endif

call Debug( "perl: [".s:perl."]" )

" Get the perl version we are compiling against
let s:perl_version_cmd = s:perl.' -v'
let s:perl_version = system(s:perl_version_cmd)
let s:perl_version = substitute(s:perl_version,'\nThis is perl, v\(\d\+\.\d\+\.\d\+\) .*built .*','\1','')
call Debug( 'perl_version: ['.s:perl_version.']' )

" Try get LIBRARY_BASE
if strlen( $LIBRARY_BASE ) == 0
    call Debug( "no LIBRARY_BASE; guessing" )
    let s:buffer = getcwd().'/'.bufname("%")
    let s:base_anchor = g:perl_compiler_base_anchor || '.'
    if s:buffer =~ s:base_anchor
        call Debug( "getcwd().bufname(%) seems to look promising; trying to strip off extraneous bits" )
        let s:pat = '\('.s:base_anchor.'\I\+\)/.*'
        call Debug( "substitute(".s:buffer.", ".s:pat.",'\1','')" )
        let $LIBRARY_BASE=substitute(s:buffer,s:pat,'\1','')
    endif
    call Debug( "Set LIBRARY_BASE [".$LIBRARY_BASE."]" )
endif

" set our starter libs
let s:perl_libs  = "\\ -I$LIBRARY_BASE/lib\\ -I$LIBRARY_BASE/sharedlib"
if has('file_in_path') && has('path_extra')
    " iterate over g:perl_compiler_lib_paths looking for lib/
    if !empty( g:perl_compiler_lib_paths )
        for s:haystack in g:perl_compiler_lib_paths
            let s:perl_libs .= s:Findlib_path(s:haystack, 'lib')
        endfor
    endif

    " we want to find Apache2/
    let s:apache_lib = s:Findlib_path('/site/httpd/**','Apache2')
    " but include the containing dir
    if strlen( s:apache_lib )
        let s:apache_lib = substitute(s:apache_lib,'/Apache2','','')
        let s:perl_libs .= s:apache_lib
    endif

    " search for oracle libs
    let s:perl_libs .= s:Findlib_file('/site/oracle_client/**','DBI.pm')
endif

call Debug( 'done finding libs' )

if exists(":CompilerSet") != 2                   " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:savecpo = &cpo
set cpo&vim

if exists('g:perl_compiler_force_warnings') && g:perl_compiler_force_warnings == 1
    let s:warnopt = '\ -W'
else
    let s:warnopt = '\ -w'
endif

if getline(1) =~# '-[^ ]*T'
    let s:taintopt = 'T'
else
    let s:taintopt = ''
endif

if exists('g:perl_compiler_run_check') && g:perl_compiler_run_check == 1
    let s:checkopt = 'C'
else
    let s:checkopt = 'c'
endif


let s:command = 'CompilerSet makeprg='.s:perl.s:perl_libs.s:warnopt.s:taintopt.s:checkopt.'\ %'
exe s:command

CompilerSet errorformat=
    \%-G%.%#had\ compilation\ errors.,
    \%-G%.%#syntax\ OK,
    \%-G%.%#used\ only\ once\:\ possible\ typo%.%#,
    \%m\ at\ %f\ line\ %l.,
    \%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
    \%+C%.%#

" Explanation:
" %-G%.%#had\ compilation\ errors.,  - Ignore the obvious.
" %-G%.%#syntax\ OK,                 - Don't include the 'a-okay' message.
" %-GName "%*[s]"used\ only\ once,          - Ignore "used only once, possible typo" messages
" %m\ at\ %f\ line\ %l.,             - Most errors...
" %+A%.%#\ at\ %f\ line\ %l\\,%.%#,  - As above, including ', near ...'
" %+C%.%#                            -   ... Which can be multi-line.

let &cpo = s:savecpo
unlet s:savecpo
