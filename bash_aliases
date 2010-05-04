#!/bin/sh
function setPerl5lib () {
	if [ -n "$1" ] ; then
		DIRPATH="$HOME/git/$1"
	else
		DIRPATH="$HOME/git/dev"
	fi

	if [ -d "$DIRPATH" ]; then
		unset PERL5LIB
		for dir in $( ls -d $DIRPATH/*/lib ); do
			if [ -z "$PERL5LIB" ]; then
				PERL5LIB=$dir
			else
				PERL5LIB=$PERL5LIB:$dir
			fi
		done
	else
		echo $DIRPATH is not valid
	fi
	export PERL5LIB
}

alias vi=$( which vim )
alias gi='gvim -rv'
alias aoeu='xmodmap ~/.anti-dvorak'
alias asdf='xmodmap ~/.qwerty'

# We want a quick alias to set our SSH_AUTH_SOCK in case we are re-connecting to a screen session
# or maybe we didn't have an agent running when we started the terminal session. The way we do this
# varies a little between Linux and Mac OS X, but since I don't want to remember two different
# aliases, let's just make the declaration of the alias smart enough to DTRT

if [ "Darwin" == $( uname ) ]; then # we are running Mac OS X or a BSD Darwin derivative
    FIND_ARGS='/tmp/launch-* -user iheffner -name Listeners'
else
    FIND_ARGS='/tmp/ssh-* -user iheffner -name '\''agent.*'\'
fi
alias sock='export SSH_AUTH_SOCK=$( echo $( find '$FIND_ARGS' 2>/dev/null ) | cut -d\  -f1 )' # grab the first socket we find
