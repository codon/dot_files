# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:/opt/local/pgsql/bin:/usr/java/jre1.5.0_06/bin:$HOME/svn/depot_tools

TUNNEL_HOST=iheffner.com
export TUNNEL_HOST

IFS='
'

hostname=$(hostname)
case $hostname in
    slugfest|bumblebee|cvs|git|vcs*)
        for x in $( ls -d /site/{marchex,perl,perllibs-xml,pulley} ) ; do
#             echo "find $x ..."
            for y in $( find $x -maxdepth 3 -name build -prune -o -name packages -prune -o -type d -name bin ) ; do
#                 echo "export PATH=$y:\$PATH"
                export PATH=$y:$PATH
            done
        done
        ;;
    *)
        if [ -d /site ] ; then
            for x in $( find /site -maxdepth 3 -type d -name bin ) ; do
                export PATH=$x:$PATH
            done
            for x in $( find /site -maxdepth 3 -type d -path '/site/perllibs*' -name lib ) ; do
                export PERL5LIB=$x:$PERL5LIB
            done
        fi
        ;;
esac

ORACLE_HOME=/site/oracle_client/client-11.2.0.1
PATH=$PATH:$ORACLE_HOME/bin
EDITOR=$(which vim)

if [ -e $HOME/.rbenv ]; then
    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
fi

# fix some environment issues
if [[ "$OSTYPE" =~ 'darwin' ]] ; then
    /bin/stty discard '^-'
fi
# stty erase 

# set \ev to edit-and-execute current command
bind '"\ev"':edit-and-execute-command

export PATH ORACLE_HOME EDITOR
unset USERNAME

# .bash_login

# Set up links to pecan shares
if [ -e ~/.xsession ]; then
	if [ -z "$SSH_AGENT_PID" ]; then
		eval $( ssh-agent )
	fi

fi

if [ -f /opt/local/etc/bash_completion ]; then
	source /opt/local/etc/bash_completion
fi

[[ -r "$HOME/.smartcd_config" ]] && source ~/.smartcd_config
