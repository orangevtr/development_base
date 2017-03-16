if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export USERDIR=${USERDIR:-$HOME}

[ -r $USERDIR/.shrc_common ] && source $USERDIR/.shrc_common

PS1='[\u@\h: \w(\j)]\$ '

export LANG=en_US.UTF-8
