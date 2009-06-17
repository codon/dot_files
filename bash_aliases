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

