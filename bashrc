# .bashrc

# Source global definitions
GLOBAL_BASH_DEF='/etc/bashrc'

# Create a scrubed hostname
export HOSTNAME_SCRUB=`hostname | sed -e s/[^a-z0-9_]//g`

# Global variables
# Sometimes EDITOR require a complete path
export EDITOR=`which vim`
export SVN_EDITOR=`which vim`
export GIT_EDITOR=`which vim`
export PAGER=`which less`
export LS_COLORS="no=00:\
fi=00:\
di=01;36:\
ln=01;36:\
pi=40;33:\
so=01;35:\
do=01;35:\
bd=40;33;01:\
cd=40;33;01:\
or=40;31;01:\
ex=01;32:\
*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:\
*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:\
*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:\
*.ogg=01;35:*.mp3=01;35:*.wav=01;35:\
";
export GREP_OPTIONS='--color=auto'
if [ -f "$HOME/.inputrc" ]; then
  export INPUTRC="$HOME/.inputrc"
fi;
export MAN_AUTOCOMP_FILE="/tmp/man_completes_`whoami`"

# Compatability options
# The BSD sed on mac uses -E, while the GNU one on linux uses -r
(echo '' | sed -r /GG/g &> /dev/null)
if [ $? -eq "0" ]; then
  export SED_EXT='-r'
else
  export SED_EXT='-E'
fi


# GNU vs BSD ls for color
(ls --color=tty &> /dev/null)
if [ $? -eq 0 ]; then
  export LS_COLOR='--color=tty'
else
  export LS_COLOR='-G'
fi;

#GNU vs BSD top command line arguments
# Delay updates by 10 sec and sort by CPU
(man top 2>&1 | grep Linux> /dev/null)
if [ $? -eq 0 ]; then
  export TOP_OPTIONS='-c -d10'
else
  export TOP_OPTIONS='-s10 -ocpu'
fi;


# Options
shopt -s checkwinsize
shopt -s histappend   # Append to history rather than overwrite
set -o vi

# Aliases
alias ls='ls -h $LS_COLOR'
alias la='ls -lah $LS_COLOR'
alias ll='ls -lh $LS_COLOR'
alias ssh='ssh -A'
alias g='git'
alias gs='git show'
alias top='top $TOP_OPTIONS'
alias rcopy='rsync -az --stats --progress --delete'
alias ..='cl ..'
alias trim_whitespace="sed -i 's/[ \t]*$//' "
alias sush='ssh -l root'
alias http_headers='curl -svo /dev/null'
alias less='less -R'
alias sshr="ssh -l root"
alias detach-all="screen -list | grep Attached | cut -f1 -d. | xargs -n1 screen -d"

# fasd aliases
alias vsf="sf -e vim"
alias tsf="sf -e t"

# git aliases
alias gb="git br -v"
alias gr="git fetch && git svn rebase"
alias gl="git log --pretty=fuller"
alias gpr="git pull --rebase"
alias gfrt="git fetch && git rebase trunk"
alias gd="git diff"
alias gfu="git ci -a --amend -C HEAD"  # fixup

# g4 piper functions
function cdg4() { g4d -f "$@" ;}

# Auto completion
complete -cf sudo
complete -cf which
#autocomplete ssh commands with the hostname
complete -W "$(echo `cat ~/.ssh/known_hosts 2> /dev/null | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

# autocomplete man commands
function listmans_raw() {
  local manpath_func
  which manpath &> /dev/null
  if [ $? -eq 0 ]; then
    manpath_func='manpath'
  else
    manpath_func='man -W 2> /dev/null'
  fi;
  for dir in $($manpath_func | /usr/bin/tr ':' '\n'); do
    find "${dir}" ! -type d -name "*.*" 2>/dev/null | sed -e 's#/.*/##g' | sed -e 's#.[^.]*$##g' | sed -e 's#\.[0123456789].*##g'
  done
}
function regen_man_args() {
  listmans_raw | sort -u > $MAN_AUTOCOMP_FILE
}
function listmans() {
  if [ ! -f $MAN_AUTOCOMP_FILE ]; then
    regen_man_args
  fi;
  cat $MAN_AUTOCOMP_FILE
}
complete -W "$(listmans)" man


#### RANDOM FUNCTIONS #####
# awesome!  CD AND LA. I never use 'cd' anymore...
function cl(){ cd "$@" && la; }
# Two standard functions to change $PATH
add_path() { export PATH="$PATH:$1"; }
add_pre_path() { export PATH="$1:$PATH"; }
# Misc utilities:

# Repeat a command N times.  You can do something like
#  repeat 3 echo 'hi'
function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}

# Lets you ask a command.  Returns '0' on 'yes'
#  ask 'Do you want to rebase?' && git svn rebase || echo 'Rebase aborted'
function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

#Simple blowfish encryption
function blow()
{
    [ -z "$1" ] && echo 'Encrypt: blow FILE' && return 1
    openssl bf-cbc -salt -in "$1" -out "$1.bf"
}
function fish()
{
    test -z "$1" -o -z "$2" && echo \
        'Decrypt: fish INFILE OUTFILE' && return 1
    openssl bf-cbc -d -salt -in "$1" -out "$2"
}

# Extract based upon file ext
function ex() {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1        ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xvf $1        ;;
             *.tbz2)      tar xvjf $1      ;;
             *.tgz)       tar xvzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
# Compress with tar + bzip2
function bz2 () {
  tar cvpjf $1.tar.bz2 $1
}

# Google the parameter
function google () {
  links http://google.com/search?q=$(echo "$@" | sed s/\ /+/g)
}

function myip () { 
 # GNU vs BSD hostname
 (hostname -i &> /dev/null)
  if [ $? -eq 0 ]; then
    echo `hostname -i`
  else
    # default to eth0 IP, for MAC
    echo `ipconfig getifaddr en0`
  fi;
}

function dumptcp() {
 # TCPDUMP all the data on port $1 into rotated files /tmp/results.  Note,
 # this can get VERY large
  sudo /usr/sbin/tcpdump -i any -s0 tcp port $1 -A -w /tmp/results -C 100
}

# anyvi <file>
# run EDITOR on a script no matter where it is
function anyvi()
{
    if [ -e "$1" ] || [ -f "$1" ]; then
        $EDITOR $1
    else
        $EDITOR `which $1`
    fi
}
complete -cf anyvi        #autocomplete the anyvi command

# Grep for a process while at the same time ignoring the grep that
# you're running.  For example
#   ps awxxx | grep java
# will show "grep java", which is probably not what you want
function psgrep(){
  local OUTFILE=`mktemp /tmp/psgrep.XXXXX`
  ps awxxx > $OUTFILE
  grep $@ $OUTFILE
  rm $OUTFILE
}

# Quick and dirty calculator.  Goes right to ruby and lets you print out
#   the results of math operations, or other ruby expressions
function calc(){ ruby -e "puts $*"; }

add_path $HOME/bin
add_path $HOME/.bash/bin
add_path $HOME/.bash/group/bin

###### PROMPT ######
# Set up the prompt colors
source $HOME/.bash/term_colors
PROMPT_COLOR=$G
if [ ${UID} -eq 0 ]; then
  PROMPT_COLOR=$R ### root is a red color prompt
fi

export CURSOR_PROMPT=">"

# I like this prompt for a few reasons:
# (1) The time shows when each command was executed, when I get back to my terminal
# (2) Git information really important for git users
# (3) Prompt color is red if I'm root
# (4) The last part of the prompt can copy/paste directly into an SCP command
# (5) Color highlight out the current directory because it's important
# (6) The export PS1 is simple to understand!
# (7) If the prev command error codes, the prompt '>' turns red
export PS1="$Y\t$N $W$N$PROMPT_COLOR\u@\H$N:$C\w$N\n$CURSOR_PROMPT "
# TODO: Find out why my $R and $N shortcuts don't work here!!!
export PROMPT_COMMAND='if [ $? -ne 0 ]; then CURSOR_PROMPT=`echo -e "\033[0;31m>\033[0m"`; else CURSOR_PROMPT=">"; fi;'

# remove duplicate path entries and preserve PATH order
export PATH=$(echo $PATH | awk -F: '
{ start=0; for (i = 1; i <= NF; i++) if (!($i in arr) && $i) {if (start!=0) printf ":";start=1; printf "%s", $i;arr[$i]}; }
END { printf "\n"; } ')
