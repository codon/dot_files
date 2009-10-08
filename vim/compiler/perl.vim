" Vim Compiler File
" Compiler:     Perl syntax checks (perl -Wc)
if exists("current_compiler")
  finish
endif
let current_compiler = "perl-next"

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

" Get the perl version we are compiling against
let s:perl_version_cmd = s:perl.' -v'
let s:perl_version = system(s:perl_version_cmd)
let s:perl_version = substitute(s:perl_version,'\nThis is perl, v\(\d\+\.\d\+\.\d\+\) .*built .*','\1','')

" set our starter libs
let s:perl_libs  = "\\ -I$MARCHEX_BASE/lib\\ -I$MARCHEX_BASE/sharedlib"
if has('file_in_path') && has('path_extra')
	" search for next libs
	let s:next_lib = finddir('perllibs-next','/site/perllibs-next')
	if s:next_lib
		s:perl_libs .= '\ -I'.s:next_lib.'/lib'
	endif
	" search for xml libs
	let s:xml_lib = finddir('perllibs-xml','/site/perllibs-xml')
	if s:xml_lib
		s:perl_libs .= '\ -I'.s:xml_lib.'/lib'
	endif
	" need to get Apache2/RequestRec.pm
	let s:apache_lib = finddir('perllibs-apache','/site/httpd-**')
	if s:apache_lib
		s:perl_libs .= '\ -I'.s:apache_lib.'/lib'
	endif
	" search for oracle libs
	let s:dbis = findfile('DBI.pm','/site/oracle_client/**',-1) " -1 means 'get all'
	let s:matches = []
	for s:dbi in s:dbis
		" make sure this DBI matches our Perl version
		if s:dbi =~ s:perl_version
			" strip out extraneous path information
			let s:dbi_lib = substitute(s:dbi,'\(perl/s:lib\)/.*','\1','')
			" check to see if we have seen this path yet
			if -1 == match(s:matches,s:dbi_lib)
				" add it to our paths to include
				let s:perl_libs .= '\ -I'.s:dbi_lib
				" and add it to our list of items seen
				let s:matches = s:matches + [s:dbi_lib]
			else
				" skip this; we've aleardy seen it
			endif
		endif
	endfor
endif

if exists(":CompilerSet") != 2                   " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:savecpo = &cpo
set cpo&vim

if exists('g:perl_compiler_force_warnings') && g:perl_compiler_force_warnings == 0
	let s:warnopt = '\ -w'
else
	let s:warnopt = '\ -W'
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
