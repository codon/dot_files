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

function git_push_workingtree() {
    remote=$1
    head_ref=$(git symbolic-ref HEAD)
    remote_ref=$( git symbolic-ref HEAD | sed 's|heads|remotes/macbook|' )
    git push $remote +$head_ref:$remote_ref
}
export -f git_push_workingtree

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

function git_cleanup() {
    if [[ -z $(sed --version 2>/dev/null) ]] ; then
        local sed_flags='-E'
    else
        local sed_flags=
    fi

    if [[ $1 != "-f" ]]; then
        echo "### Dry-run mode, specify -f to actually perform deletes."
    fi
    for branch in $(git branch -r --merged origin/master | sed $sed_flags "s/^[[:space:]]*//" | grep '\<origin/' | grep -v '\<origin/master\>'); do
        if [[ -z $(git rev-list $branch --since '1 month') ]]; then
            name=$(echo $branch | sed 's/^origin\///')
            if [[ $1 = "-f" ]]; then
                git push --delete origin "$name"
            else
                echo git push --delete origin "$name"
            fi
        fi
    done
}
export -f git_cleanup

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

function rehost() {
    if [[  1 != $#  ]]; then
        echo "Usage: rehost host" >&2
        return 1
    fi
    local host="$1"
    pushd ~ > /dev/null
    # .gitconfig
    scp -r .git* .ssh .vim* .bash* .screen* $host:.
    ssh $host "[[ -f .bash_history ]] && mv -i .bash_history .hist_bash"
    popd > /dev/null
}

function rspcap() {
    for host in n{x,im}c{r,p}{1,2,3,4,5,6,7,8}.{sad,stg,qa,devint} vspbxuti1.sea ; do
        rsync -vaz $host:/tmp/*.pcap $HOME/tcpdumps/$host/ 2>/dev/null
    done
}

function mk_user_lib() {
    /site/perl/perl-5.10.1-1/bin/perl Makefile.PL \
        PREFIX=$HOME/git/user_service/perllibs
        INSTALLMAN1DIR=$HOME/git/user_service/perllibs/man1   \
        INSTALLMAN3DIR=$HOME/git/user_service/perllibs/man3   \
        LIB=$HOME/git/user_service/perllibs
    make && make test && make install
}


alias vi=$( which vim )
alias gi='gvim -rv'
alias aoeu='xmodmap ~/.anti-dvorak'
alias asdf='xmodmap ~/.qwerty'
alias htunnel='ssh -L 5901:littleone.iheffner.com:5900 -p2222 root@heimdall.iheffner.com'
alias share='open /System/Library/CoreServices/Screen\ Sharing.app'
alias sqlplus='rlwrap sqlplus'
alias perldoc='perldoc -t'

alias share='open /System/Library/CoreServices/Screen\ Sharing.app'
alias sqlplus='rlwrap sqlplus'
alias perldoc='perldoc -t'

alias rdp='rdesktop -g 1280x900 terminal1sea.windows.marchex.com'
alias gf='git fetch'
alias gp='git push'
alias grb='git rebase'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add'
alias gap='git add -p'
alias gl='git log'
alias gls='git log --stat'
alias gg='git graph'
alias gump='gmup'
alias gmup='git merge @{u}'
alias grup='git rebase @{u}'
alias tcpd='sudo tcpdump -p -i any -s0 -v -w /tmp/$(hostname).$(date +%F-%T).pcap udp and not port 53 and not arp'
alias rstcpd='for h in nxc{r{1,2},p{1,2,3,4,5,6,7,8}}.sad ; do rsync -varz $h:/tmp/*.pcap tcpdumps/$h/ ; done'
alias path_clean='eval $( perl -wle '\''my %path = map { $_ => 1 } grep { !/tags/ && !m[lib/\w+/bin] && 6>scalar(()=m[/]g) } split /:/, $ENV{PATH}; $"=q{:}; print "export PATH=".join $", keys %path'\'' )'


function mk_lib() {
    target=$1
    if [ -z "$target" ] ; then
        echo "please specify the target installation path"
        return
    fi
    if [ ! -d $target ] ; then
        echo "$target does not exist. create? [Y/n] "
        read create_target
        # if [[ [ "Y" eq $create_target ] || [ "y" eq $create_target ] || [ -z "$create_target" ] ]] ; then
        if [[ "Y" -eq $create_target || "y" -eq $create_target || -z "$create_target" ]] ; then
            mkdir $target
        fi
    fi
    /site/perl/perl-5.10.1-1/bin/perl Makefile.PL    \
        PREFIX=$target                               \
        INSTALLMAN1DIR=$target                       \
        INSTALLMAN3DIR=$target                       \
        LIB=$target
    make && make test && make install
}

