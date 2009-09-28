
" Remove any old syntax stuff that was loaded (5.x) or quit when a syntax file
" was already loaded (6.x).
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Unset perl_fold if it set but vim doesn't support it.
if version < 600 && exists("perl_fold")
  unlet perl_fold
endif


" POD starts with ^=<word> and ends with ^=cut

if exists("perl_include_pod")
  " Include a while extra syntax file
  syn include @Pod syntax/pod.vim
  unlet b:current_syntax
  if exists("perl_fold")
    syn region perlPOD start="^=[a-z]" end="^=cut" contains=@Pod,@Spell,perlTodo keepend fold
    syn region perlPOD start="^=cut" end="^=cut" contains=perlTodo keepend fold
  else
    syn region perlPOD start="^=[a-z]" end="^=cut" contains=@Pod,@Spell,perlTodo keepend
    syn region perlPOD start="^=cut" end="^=cut" contains=perlTodo keepend
  endif
else
  " Use only the bare minimum of rules
  if exists("perl_fold")
    syn region perlPOD start="^=[a-z]" end="^=cut" contains=@Spell fold
  else
    syn region perlPOD start="^=[a-z]" end="^=cut" contains=@Spell
  endif
endif

syn match   perlStatementInclude	"\<\(use\|no\)\s\+\(\(attributes\|autouse\|base\|big\(int\|num\|rat\)\|blib\|bytes\|charnames\|constant\|diagnostics\|encoding\|fields\|filetest\|if\|integer\|less\|lib\|locale\|open\|ops\|overload\|re\|sigtrap\|sort\|strict\|subs\|threads\(::shared\)\=\|utf8\|vars\|vmsish\|warnings\(::register\)\=\)\>\)\="

syn match  perlVarPlain		 "$[\\\"\[\]'&`+*.,;=%~?@$<>(-]"
syn match  perlVarPlain		 "$\(0\|[1-9]\d*\)"
" This variable is not recognized within matches delimited by '!'.
syn match  perlVarBang		 "$!"
" FIXME value between {} should be marked as string. is treated as such by Perl.
" At the moment it is marked as something greyish instead of read. Probably todo
" with transparency. Or maybe we should handle the bare word in that case. or make it into

if !exists("perl_no_scope_in_variables")
  syn match  perlVarPlain	"\\\=\([@%$]\|\$#\)\$*\(\I\i*\)\=\(\(::\|'\)\I\i*\)*\>" contains=perlPackageRef nextgroup=perlVarMember,perlVarSimpleMember,perlMethod
  syn match  perlFunctionName	"\\\=&\$*\(\I\i*\)\=\(\(::\|'\)\I\i*\)*\>" contains=perlPackageRef nextgroup=perlVarMember,perlVarSimpleMember
else
  syn match  perlVarPlain	"\\\=\([@%$]\|\$#\)\$*\(\I\i*\)\=\(\(::\|'\)\I\i*\)*\>" nextgroup=perlVarMember,perlVarSimpleMember,perlMethod
  syn match  perlFunctionName	"\\\=&\$*\(\I\i*\)\=\(\(::\|'\)\I\i*\)*\>" nextgroup=perlVarMember,perlVarSimpleMember
endif

syn match  perlFiledescStatementNocomma "(\=\s*\u\w*\s*[^,[:space:]]"me=e-1 transparent contained contains=perlFiledescStatement
syn match  perlSpecialMatch	"{\d\+\(,\d*\)\=}" contained
syn match  perlSpecialMatch	"(?<[=!]" contained
syn cluster perlInterpDQ	contains=perlSpecialString,perlVarPlain,perlVarNotInMatches,perlVarSlash,perlVarBang,perlVarBlock
syn cluster perlInterpMatch	contains=@perlInterpSlash,perlVarSlash,perlVarBang
syn region perlMatch	matchgroup=perlMatchStartEnd start=+[m!]/+ end=+/[cgimosx]*+ contains=@perlInterpSlash,perlComment
syn region perlMatch	matchgroup=perlMatchStartEnd start=+[m!]#+ end=+#[cgimosx]*+ contains=@perlInterpMatch,perlComment
syn region perlMatch	matchgroup=perlMatchStartEnd start=+[m!]{+ end=+}[cgimosx]*+ contains=@perlInterpMatch,perlComment
syn region perlMatch	matchgroup=perlMatchStartEnd start=+[!]*m!+ end=+![cgimosx]*+ contains=@perlInterpMatch,perlComment
syn region perlMatch	matchgroup=perlMatchStartEnd start=+[m!]\[+ end=+\][cgimosx]*+ contains=@perlInterpMatch,perlComment

" Below some hacks to recognise the // variant. This is virtually impossible to catch in all
" cases as the / is used in so many other ways, but these should be the most obvious ones.
syn region perlMatch	matchgroup=perlMatchStartEnd start=+^split /+lc=5 start=+[^$@%&]\<split /+lc=6 start=+^while /+lc=5 start=+[^$@%&]while /+lc=6 start=+^if /+lc=2 start=+[^$@%&]if /+lc=3 start=+[!=]\~\s*/+lc=2 start=+[(~]/+lc=1 start=+\.\./+lc=2 start=+\s/[^=[:space:][:digit:]$@%&]+lc=1,me=e-1,rs=e-1 start=+^/+ skip=+\\/+ end=+/[cgimosx]*+ contains=@perlInterpSlash

" Parentheses in qq()
syn region perlParens	start=+(+ end=+)+ contained transparent contains=perlParens,@perlStringSQ

syn region perlStringUnexpanded	matchgroup=perlStringStartEnd start="'" end="'" contains=@Spell,@perlInterpSQ
syn region perlString		matchgroup=perlStringStartEnd start=+"+  end=+"+ contains=@Spell,@perlInterpDQ
syn region perlQQ		matchgroup=perlStringStartEnd start=+\<q(+ end=+)+ contains=@perlInterpSQ,perlParens
syn region perlQQ		matchgroup=perlStringStartEnd start=+\<q[qx](+ end=+)+ contains=@perlInterpDQ,perlParens
syn region perlQQ		matchgroup=perlStringStartEnd start=+\<qw(+  end=+)+ contains=@perlInterpSQ,perlParens
" Constructs such as print <<EOF [...] EOF, 'here' documents
"
if version >= 600
  " XXX Any statements after the identifier are in perlString colour (i.e.
  " 'if $a' in 'print <<EOF if $a').
  if exists("perl_fold")
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\z(\I\i*\)+    end=+^\z1$+ contains=@perlInterpDQ fold
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\s*""+         end=+^$+    contains=@perlInterpDQ,perlNotEmptyLine fold
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\s*''+         end=+^$+    contains=@perlInterpSQ,perlNotEmptyLine fold
  else
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\z(\I\i*\)+    end=+^\z1$+ contains=@perlInterpDQ
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\s*""+         end=+^$+    contains=@perlInterpDQ,perlNotEmptyLine
    syn region perlHereDoc	matchgroup=perlStringStartEnd start=+<<\s*''+         end=+^$+    contains=@perlInterpSQ,perlNotEmptyLine
  endif
endif

" All other # are comments, except ^#!
syn match  perlComment		"#.*" contains=@Spell,perlTodo
syn match  perlSharpBang	"^#!.*"

"
" Folding

if exists("perl_fold")
  syn region perlPackageFold start="^package \S\+;$" end="^1;$" end="\n\+package"me=s-1 transparent fold keepend
  syn region perlSubFold     start="^\z(\s*\)\<sub\>.*[^};]$" end="^\z1}\s*$" end="^\z1}\s*\#.*$" transparent fold keepend
  syn region perlBEGINENDFold start="^\z(\s*\)\<\(BEGIN\|END\|CHECK\|INIT\)\>.*[^};]$" end="^\z1}\s*$" transparent fold keepend

  if exists("perl_fold_blocks")
    syn region perlIfFold start="^\z(\s*\)\(if\|unless\|for\|while\|until\)\s*(.*)\(\s*{\)\=\s*$" start="^\z(\s*\)foreach\s*\(\(my\|our\)\=\s*\S\+\s*\)\=(.*)\(\s*{\)\=\s*$" start="\z(\s*\)else\s*{\s*$" end="^\z1}\s*;\=$" transparent fold keepend
    syn region perlIfFold start="^\z(\s*\)do\(\s*{\)\=\s*$" end="^\z1}\s*while" end="^\z1}\s*;\=$" transparent fold keepend
  endif

else
  " fromstart above seems to set minlines even if perl_fold is not set.
  syn sync minlines=0
endif


if version >= 508 || !exists("did_perl_syn_inits")
  HiLink perlVarBang		perlIdentifier
  if version < 600
    HiLink perlUntilEOF		perlString		
  endif
  HiLink perlStatementInclude	perlInclude
  
  HiLink perlParens		Error
  
endif
