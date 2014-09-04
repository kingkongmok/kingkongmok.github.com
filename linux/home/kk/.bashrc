# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past t
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.

#-------------------------------------------------------------
# Greeting, motd etc...
#-------------------------------------------------------------

# Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'              # No Color
# --> Nice. Has the same effect as using "ansi.sys" in DOS.


# Looks best on a terminal with black background.....
echo -e "${CYAN}This is ${RED}${HOSTNAME}${CYAN}. You're ${RED}${USER}${CYAN} from ${RED}$DISPLAY${NC}"
date
echo 
if [ -x /usr/bin/fortune ]; then
    /usr/bin/fortune -s | cowsay     # Makes our day a bit more fun.... :-)
fi

#if [ -x /usr/bin/curl ] ; then
#   curl -s "http://www.weather.com.cn/data/sk/101280101.html"|awk -F '[,:]' '{printf ("%s,%s:%s,温度:%s°C,%s:%s,湿度:%s\n"),$3,$17,$18,$7,$9,$11,$13}'|sed 's/"//g' 
#fi

function _exit()        # Function to run upon exit of shell.
{
    echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT


#-------------------------------------------------------------
# Shell Prompt
#-------------------------------------------------------------


# to enable bash completion, install app-shells/bash-completion
. /etc/profile.d/bash-completion.sh

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=30000
HISTFILESIZE=30000

# Display Date And Time For Each Command
HISTTIMEFORMAT="%F %T "

# check the window size after each command and, if necessary,
# some more ls aliases
# some more ls aliases
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias ll='ls -alF'
alias la='ls -A'
alias ll='ls -alF'
alias la='ls -A'
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#-------------------------------------------------------------------------------
#  edit by kk here
#-------------------------------------------------------------------------------
MAIL=~/.mail/mbox
MAILCHECK=30
MAILPATH=~/.mail/mbox?"You have mail"
export PATH=$PATH:~/bin/


alias ls='ls --color=auto --time-style=long-iso'
alias l='locate -i -r'
alias s='sdcv'
alias mysql='mysql --sigint-ignore'
alias grep='grep --perl-regexp --color=auto'
alias g='grep --perl-regexp --color=auto'
alias mv='mv -i'
alias cp='cp -i'
