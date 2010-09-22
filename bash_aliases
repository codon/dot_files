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

function git_only() {
    opts=$(git rev-parse --no-revs "$@" 2>/dev/null)
    rev=$(git rev-parse --revs-only "$@" 2>/dev/null)
    if [[ -z $rev ]]; then
        branch=$(git name-rev --name-only HEAD)
    else
        branch=$rev
    fi
    git log $(git rev-parse --not --remotes --branches | grep -v $(git rev-parse $branch)) $branch $opts
}

export -f git_only

# We want a quick alias to set our SSH_AUTH_SOCK in case we are re-connecting to a screen session
# or maybe we didn't have an agent running when we started the terminal session. The way we do this
# varies a little between Linux and Mac OS X, but since I don't want to remember two different
# aliases, let's just make the declaration of the alias smart enough to DTRT
function set_agent () {
    if [ "Darwin" == $( uname ) ]; then # we are running Mac OS X or a BSD Darwin derivative
        FIND_ARGS="/tmp/launch-* -user $USER -name Listeners"
    else
        FIND_ARGS="/tmp/ssh-* -user $USER -name 'agent.*'"
    fi

    AGENT=$( echo $( eval "find $FIND_ARGS 2>/dev/null" ) | cut -d\  -f1 )

    if [ -z "$AGENT" ] ; then # no agent? Start one
        eval $(ssh-agent)
        ssh-add
    else
        export SSH_AUTH_SOCK=$AGENT
    fi
}
# I'm lazy and just want to type "sock"
alias sock=set_agent

rehost() {
    if [[  1 != $#  ]]; then
        echo "Usage: rehost host" >&2
        return 1
    fi
    local host="$1"
    pushd ~ > /dev/null
    # .gitconfig
    scp -r .ssh .vim* .bash* .screen* $host:.
    ssh $host "[[ -f .bash_history ]] && mv -i .bash_history .hist_bash"
    ssh $host rm -f .bash_rc .bash_aliases
    popd > /dev/null
}

alias vi=$( which vim )
alias gi='gvim -rv'
alias aoeu='xmodmap ~/.anti-dvorak'
alias asdf='xmodmap ~/.qwerty'

alias mk_next_lib='/site/perl/perl-5.10.1-1/bin/perl Makefile.PL PREFIX=/site/perllibs-next INSTALLMAN1DIR=/site/perllibs-next/man1 INSTALLMAN3DIR=/site/perllibs-next/man3 LIB=/site/perllibs-next/lib'
alias gf='git fetch'
alias gp='git push'
alias grb='git rebase'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add'
alias gap='git add -p'
alias gl='git log'
alias gls='git log --stat'
