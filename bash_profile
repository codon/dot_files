# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

TUNNEL_HOST=iheffner.com
export TUNNEL_HOST

IFS='
'

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

export PATH EDITOR
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
