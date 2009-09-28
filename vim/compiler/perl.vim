" Vim Compiler File
" Compiler:     Perl syntax checks (perl -Wc)
if exists("current_compiler")
  finish
endif
let current_compiler = "perl-next"

let s:perl = '/site/perl/perl-5.10.1/bin/perl'
let s:perl_libs = "I/site/perllibs-next/lib\\ -I$MARCHEX_BASE/lib\\ -I$MARCHEX_BASE/sharedlib\\ -"
if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:savecpo = &cpo
set cpo&vim

if exists('g:perl_compiler_force_warnings') && g:perl_compiler_force_warnings == 0
	let s:warnopt = 'w'
else
	let s:warnopt = 'W'
endif

if getline(1) =~# '-[^ ]*T'
	let s:taintopt = 'T'
else
	let s:taintopt = ''
endif

exe 'CompilerSet makeprg='.s:perl.'\ -'.s:perl_libs.s:warnopt.s:taintopt.'C\ %'

CompilerSet errorformat=
	\%-G%.%#had\ compilation\ errors.,
	\%-G%.%#syntax\ OK,
	\%m\ at\ %f\ line\ %l.,
	\%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
	\%+C%.%#

" Explanation:
" %-G%.%#had\ compilation\ errors.,  - Ignore the obvious.
" %-G%.%#syntax\ OK,                 - Don't include the 'a-okay' message.
" %m\ at\ %f\ line\ %l.,             - Most errors...
" %+A%.%#\ at\ %f\ line\ %l\\,%.%#,  - As above, including ', near ...'
" %+C%.%#                            -   ... Which can be multi-line.

let &cpo = s:savecpo
unlet s:savecpo
