# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

export BASHRC_READ=1

export PATH=${HOME}/.bin:/usr/local/bin:${PATH}

QT_CLANG_DIR="${HOME}/Qt/5.8/clang_64/bin"
if [[ -d "${QT_CLANG_DIR}" ]] ; then
    export PATH=${QT_CLANG_DIR}:${PATH}
fi

#### BEGIN CONFIGS FOR YOU.I ####

export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=/usr/local/opt/android-sdk
eval "$(rbenv init -)"

#### END CONFIGS FOR YOU.I ####

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Disable completion when the input buffer is empty.  i.e. Hitting tab
# and waiting a long time for bash to expand all of $PATH.
shopt -s no_empty_cmd_completion

# Enable history appending instead of overwriting when exiting.  #139609
shopt -s histappend

# Save each command to the history file as it's executed.  #517342
# This does mean sessions get interleaved when reading later on, but this
# way the history is always up to date.  History is not synced across live
# sessions though; that is what `history -n` does.
# Disabled by default due to concerns related to system recovery when $HOME
# is under duress, or lives somewhere flaky (like NFS).  Constantly syncing
# the history will halt the shell prompt until it's finished.
#PROMPT_COMMAND='history -a'

# Change the window title of X terminals 
case ${TERM} in
    [aEkx]term*|rxvt*|gnome*|konsole*|interix)
        PS1='\[\033]0;\u@\h:\w\007\]'
        ;;
    screen*)
        PS1='\[\033k\u@\h:\w\033\\\]'
        ;;
    *)
        unset PS1
        ;;
esac

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.
# We run dircolors directly due to its changes in file syntax and
# terminal name patching.
use_color=false
if type -P dircolors >/dev/null ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    LS_COLORS=
    if [[ -f ~/.dir_colors ]] ; then
        eval "$(dircolors -b ~/.dir_colors)"
    elif [[ -f /etc/DIR_COLORS ]] ; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
    # Note: We always evaluate the LS_COLORS setting even when it's the
    # default.  If it isn't set, then `ls` will only colorize by default
    # based on file attributes and ignore extensions (even the compiled
    # in defaults of dircolors). #583814
    if [[ -n ${LS_COLORS:+set} ]] ; then
        use_color=true
    else
        # Delete it if it's empty as it's useless in that case.
        unset LS_COLORS
    fi
else
    # Some systems (e.g. BSD & embedded) don't typically come with
    # dircolors so we need to hardcode some terminals in here.
    case ${TERM} in
    [aEkx]term*|rxvt*|gnome*|konsole*|screen|cons25|*color) use_color=true;;
    esac
fi

if ${use_color} ; then
    if [[ ${EUID} == 0 ]] ; then
        PS1+='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1+='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    fi

    #BSD#@export CLICOLOR=1
    #GNU#@alias ls='ls --color=auto'
    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
    alias fgrep='fgrep --colour=auto'
else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1+='\u@\h \W \$ '
    else
        PS1+='\u@\h \w \$ '
    fi
fi

for sh in /etc/bash/bashrc.d/* ; do
    [[ -r ${sh} ]] && source "${sh}"
done

# My additions

ls_dir_color='gx'
ls_symlink_color='fx'
ls_socket_color='cx'
ls_pipe_color='dx'
ls_exec_color='bx'
ls_blockspecial_color='eg'
ls_charspecial_color='ed'
ls_execuid_color='ab'
ls_execguid_color='ag'
ls_dirotherstick_color='ac'
ls_dirothernostick_color='ad'

export LSCOLORS="$ls_dir_color$ls_symlink_color$ls_socket_color$ls_pipe_color$ls_exec_color$ls_blockspecial_color$ls_charspecial_color$ls_execuid_color$ls_execguid_color$ls_dirotherstick_color$ls_dirothernostick_color"

export CLICOLOR=1

# Set smart completion of commands
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

# configure less to use colors
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# configure man to use different colors
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

alias kate='/Applications/kate.app/Contents/MacOS/kate'
alias qtc='~/Qt/Qt\ Creator.app/Contents/MacOS/Qt\ Creator'
alias gits='git status'
alias mpl='mplayer -vo gl:backend=4:glfinish'
alias mplfs='mplayer -fs -vo gl:backend=2'

start_qtc() {
    nohup ~/Qt/Qt\ Creator.app/Contents/MacOS/Qt\ Creator "$@" 1>/dev/null 2>/dev/null &
}

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="\n\[\e[1;30m\][$$:$PPID - \j:\!\[\e[1;30m\]]\[\e[0;36m\] \t \[\e[1;30m\][\[\e[1;34m\]\u@\h\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY:-o} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \[\033[33m\]\$(parse_git_branch)\[\033[00m\] \n\$ "

# Try to keep environment pollution down, EPA loves us.
unset use_color sh
