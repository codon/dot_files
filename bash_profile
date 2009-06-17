# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:/opt/local/pgsql/bin:$HOME/bin
# ~mds set path to manually installed java
TUNNEL_HOST=
export TUNNEL_HOST

PATH=$PATH:/opt/local/bin:/opt/local/sbin:/usr/java/jre1.5.0_06/bin:$HOME/bin
ORACLE_HOME=/opt/oracle/product/current
PATH=$PATH:$ORACLE_HOME/bin

# fix some environment issues
# stty erase 

export PATH
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
