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

PATH=$PATH:/opt/local/bin:/opt/local/sbin:/usr/java/jre1.5.0_06/bin:$HOME/bin:$HOME/svn/depot_tools

IFS='
'
if [[ $(hostname) =~ 'slugfest' || $(hostname) =~ 'bumblebee' ]] ; then
	for x in $( ls -d /site/{marchex,perl,perllibs-xml,pulley} ) ; do
# 		echo "find $x ..."
		for y in $( find $x -name build -prune -o -name packages -prune -o -type d -name bin ) ; do
# 			echo "export PATH=$y:\$PATH"
			export PATH=$y:$PATH
		done
	done
else
	for x in $( find /site -type d -name bin ) ; do
		export PATH=$x:$PATH
	done
	for x in $( find /site -type d -path '/site/perllibs*' -name lib ) ; do
		export PERL5LIB=$x:$PERL5LIB
	done
fi

ORACLE_HOME=/site/oracle_client/client-11.2.0.1
PATH=$PATH:$ORACLE_HOME/bin

# fix some environment issues
# stty erase 

export PATH ORACLE_HOME
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
