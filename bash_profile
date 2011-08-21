# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:/opt/local/pgsql/bin:$HOME/bin
# ~mds set path to manually installed java
TUNNEL_HOST=iheffner.com
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

ORACLE_HOME=/opt/oracle/product/current
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

##
# Your previous /Users/iheffner/.bash_profile file was backed up as /Users/iheffner/.bash_profile.macports-saved_2011-03-22_at_16:49:08
##

# MacPorts Installer addition on 2011-03-22_at_16:49:08: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.
