"
" Perl Subroutine Folding expression
function! GetPerlFold()
	if getline(v:lnum) =~ '^\s*sub\>'
		return "a1"
	elseif getline(v:lnum + 2) =~ '^\s*sub\>' && getline(v:lnum + 1) =~ '^\s*$'
		return "s1"
	elseif getline(v:lnum) =~ '^{\s*\(#.*\)*$'
		return "a1"
	elseif getline(v:lnum) =~ '^}\s*\(#.*\)*$'
		return "s1"
	else
		return "="
	endif
endfunction

set cinkeys&
set cinkeys-=0#
set cinwords&
set cinwords+=elsif,foreach,sub,unless,until
set cinoptions&
set cinoptions+=+2s,(1s,u0,m1
set cindent
set iskeyword&
set iskeyword+=:
set formatoptions-=r
let g:perl_compiler_base_anchor='/\%(next\|nim\|user_service\)/'   " TIL: \%(..\) is vim's non-capturing pattern match
let g:perl_compiler_lib_paths=['/site/perllibs-dcm/**','/site/perllibs-nim/**','/site/perllibs-next/**','/site/perllibs-xml/**']
compiler! perl
let $MARCHEX_BASE=$LIBRARY_BASE
"
" compile current file
map !! :make<CR>
map ,n :cn<CR>
map ,p :cp<CR>
"
" find and open the source to the module name currently under the cursor
" (relies on $PERL5LIB)
map \p :sp `perldoc -l -m <C-r><C-w>`<CR>
ab lisdb ($logger->is_debug())
ab ldb logger->debug
ab udd use Data::Dumper
ab pdd print Dumper
ab wdd warn Dumper
let perl_extended_vars = 1
let perl_sync_dist = 100
let perl_fold = 1
let b:commentChar = "#"

if has( "folding" )
	set maxfuncdepth=1000
	set foldexpr=GetPerlFold()
"	set foldmethod=expr
	set foldmethod=syntax
endif

" ------------------------------------------------------------------------------
" A really nice status bar.  ( Probably only works with newer version of VIM )
" ------------------------------------------------------------------------------
" This is rather lame: statusline is a global option, not per-buffer. That
" means we need to recreate the entire status line when we load a perl file
" just so we can get the current subroutine.
if exists('g:loaded_fugitive')                           " make sure we have fugitive
    set statusline=%{fugitive#statusline()}\             " current git branch
else
    set statusline=                                      " blank
endif

set statusline+=%f                                       " filename

if &ft == "perl"
    set statusline+=%{CurrSubName()}\                    " current (Perl) subroutine
endif

set statusline+=%{StatuslineTrailingSpaceWarning()}\     " trailing space warning
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*
set statusline+=%#warningmsg#
set statusline+=%{&paste?'[*]':''}
set statusline+=%*
set statusline+=%m%h%r\                                  " modifed, help, readonly
set statusline+=%=%25(%17(%c%V\,%l\ \(%L\)%)\ %p%%%)     " column, virtual column,
                                                         " current line, total linecount
                                                         " percent through file
