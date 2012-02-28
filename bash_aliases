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

function nxcp.exec () {
    cmd=$1
    echo "running '$cmd' against all call processors. Hit ENTER to continue."
    read enter
    sock
    for x in 1 2 3 4 5 6 7 8 ; do
        nxcp="nxcp${x}.sad"
        echo "$nxcp"
        ssh -t $nxcp "sudo /site/asterisk/asterisk-1.6.2.6/sbin/asterisk -C /site/nx-call-proc-ast-conf/conf/asterisk.conf -rx '$cmd'"
        echo "====="
    done
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

function git_cleanup() {
    if [[ $1 != "-f" ]]; then
        echo "### Dry-run mode, specify -f to actually perform deletes."
    fi
    for branch in $(git branch -r --merged origin/master | sed 's/^\s\+//' | grep '\<origin/' | grep -v '\<origin/master\>'); do
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

function cgtest() {
    if [ -z "$1" ] ; then
        echo "where should I start?"
        return -1;
    fi
    base=$1
    (
        cd $HOME/git/$base
        for dir in $( ls ) ; do
            if [ -d "$dir/templates" ] ; then
                (
                    cd $dir
                    echo -n "$dir: "
                    confgen 1>/dev/null 2>&1
                    if [ 0 -eq $? ] ; then
                        confgen --dev 1>/dev/null 2>&1
                        if [ 0 -eq $? ] ; then
                            echo 'ok'
                        else
                            echo 'has errors'
                            break
                        fi
                    else
                        echo 'has errors'
                        break
                    fi
                )
            else
                echo "$dir: skipped"
            fi
        done
    )
}

function _service () {
    service=$1
    action=$2
    case $action in
        'stop')
            echo -n "stopping $service ... "
            $service stop 2>/dev/null 1>&2
            if [ 0 == $? ] ; then
                echo "[ok]"
            else
                echo "[ERROR]"
            fi
            ;;
        'start')
            echo -n "starting $service ... "
            $service start 2>/dev/null 1>&2
            if [ 0 == $? ] ; then
                echo "[ok]"
            else
                echo "[ERROR]"
            fi
            ;;
        *)
            echo "you don't know what you're talking about, do you?"
            ;;
    esac
}

function _services () {
    action=$1
    shift
    for service in $* ; do
        (
            cd $service
            echo -n "$service: "
            _service bin/httpd $action
        )
    done
}

function _get_git_base () {
    GIT_BASE=$HOME/git/next
    if [ ! -d $GIT_BASE ] ; then
        echo "where is your working 'next' directory?"
        read GIT_BASE
    fi
    echo $GIT_BASE
}

function mx_basic_start () {
    GIT_BASE=$(_get_git_base)
    (
        cd $GIT_BASE
        _services start utility_api user_api mgmt_api mgmt_ui
    )
}

function mx_basic_stop () {
    GIT_BASE=$(_get_git_base)
    (
        cd $GIT_BASE
        _services stop mgmt_ui mgmt_api user_api utility_api
    )
}

alias mx_basic_restart='mx_basic_stop && mx_basic_start'

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
    scp -r .git* .ssh .vim* .bash* .screen* $host:.
    ssh $host "[[ -f .bash_history ]] && mv -i .bash_history .hist_bash"
    popd > /dev/null
}

rspcap() {
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
alias tcpd='sudo tcpdump -p -i any -s0 -v -w /tmp/$(hostname).$(date +%F-%T).pcap udp and not port 53 and not arp'
alias rstcpd='for h in nxc{r{1,2},p{1,2,3,4,5,6,7,8}}.sad ; do rsync -varz $h:/tmp/*.pcap tcpdumps/$h/ ; done'
alias path_clean='eval $( perl -wle '\''my %path = map { $_ => 1 } grep { !/tags/ && !m[lib/\w+/bin] && 6>scalar(()=m[/]g) } split /:/, $ENV{PATH}; $"=q{:}; print "export PATH=".join $", keys %path'\'' )'

alias port='PATH=/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin sudo port'

function call_stack() {
    $HOME/bin/mxctl.pl $* \
            storage_api\
            cs_redis_conf\
            cs_publisher\
            call_settings\
            pp_ast_conf\
            playfile_publisher\
            call_processor\
            cp_ast_conf\
            cr_opensips_conf\
            log_mover\
            listing_grinder\
            queue_grinder\
            log_processor
}

function nim_stack() {
    $HOME/bin/mxctl.pl $* \
            redis_conf\
            redis_publisher\
            product_api\
            call_api\
            queue_grinder\
            call_api\
            call_processor_httpd\
            call_processor_asterisk_conf\
            call_router\
            log_processor
}

alias bounce="$HOME/git/next-dev/tools/mxctl.pl bounce"

function fetch_cs() {
    host='csapi.next.marchex.com'
    carrier=skype
    while [ -n "$2" ] ; do
        case $1 in
            --carrier=*)
                carrier=${1/#--carrier=/}
                shift
                ;;
            --carrier|-c)
                shift
                carrier=$1
                shift
                ;;
            --dev|-d)
                host='localhost:8877'
                shift
                ;;
            *)
                echo "don't recognize option '$1'; did you mean --$1?"
                return
                ;;
        esac
    done

    ctn=${1/#+/%2b}
    url="http://$host/api/v1/settings/get?call_id=manual_check&caller_id=cli&carrier=${carrier}&tracking_phone=$ctn"
    echo "curl $url"
    curl $url
    echo
}

function mk_next_lib() {
    /site/perl/perl-5.10.1-1/bin/perl Makefile.PL \
        PREFIX=/site/perllibs-next                \
        INSTALLMAN1DIR=/site/perllibs-next/man1   \
        INSTALLMAN3DIR=/site/perllibs-next/man3   \
        LIB=/site/perllibs-next/lib
    make && make test && make install
}

function running_next() {
    for pid in $( cat */run/*.pid ) ; do
        process=$( ps wup $pid | grep "\\<$pid\\>" )
        if [ -n "$process" ] ; then
            echo "$pid still running"
            echo $process
        fi
    done
}

function action_all_dcm_services() {
    host=$1
    action=$2
    passwd=$3

    if [ -z "$passwd" ]
    then
        read -s -p "Sudo password for $host: " passwd
    fi

    /usr/bin/ssh $host << EOS
        echo $passwd | sudo -l;
        for service in /etc/init.d/dcm-*;
        do
            sudo \$service $action;
        done;
        sudo -k # kill sudo cred;
EOS
}

function dcm_stop() {
    read -s -p "Sudo password: " passwd
    for host in $* ; do
        action_all_dcm_services $host stop "$passwd"
    done
}

function dcm_start() {
    read -s -p "Sudo password: " passwd
    for host in $* ; do
        action_all_dcm_services $host start "$passwd"
    done
}
