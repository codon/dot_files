"
" Perl Subroutine Folding expression
function! GetPerlFold()
	if getline(v:lnum) =~ '^\s*sub\>'
		return "a1"
	elseif getline(v:lnum + 2) =~ '^\s*sub\>' && getline(v:lnum + 1) =~ '^\s*$'
		return "s1"
	elseif getline(v:lnum) =~ '^{\s*$'
		return "a1"
	elseif getline(v:lnum) =~ '^}\s*$'
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
compiler! perl
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
" ------------------------------------------------------------------------------
" A really nice status bar.  ( Probably only works with newer version of VIM )
" ------------------------------------------------------------------------------
if has( "folding" )
	set statusline=%f%{CurrSubName()}\ %m%h%r\ %=%25(%-17(%l\,%c%V%)\ %p%%%)
	set laststatus=2
	set maxfuncdepth=1000
	set foldexpr=GetPerlFold()
"	set foldmethod=expr
	set foldmethod=syntax
endif

