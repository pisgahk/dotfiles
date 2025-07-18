# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

fastfetch

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
. "$HOME/.cargo/env"

#My aliases
alias ls='ls -la --color=auto'
alias venv-banana='python3 -m venv .venv'
alias activate='source ./.venv/bin/activate'

# adding this to make my terminal have a beautiful "shell prompt style."
# Custom prompt with brackets and lines
#PS1='\[\033[0;36m\]┌──(\[\033[0;34m\]\u\[\033[0;36m\]@\[\033[0;34m\]\h\[\033[0;36m\])-[\[\033[0;37m\]\w\[\033[0;36m\]]\n└─\[\033[0;34m\]$\[\033[0m\] '

# Enhanced Bash prompt with Git support

# Git prompt function
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

parse_git_status() {
    local git_status=""
    local git_dir="$(git rev-parse --git-dir 2>/dev/null)"

    if [ -n "$git_dir" ]; then
        # Check for uncommitted changes
        if [[ $(git diff --shortstat 2>/dev/null | tail -n1) != "" ]]; then
            git_status="${git_status}*"
        fi

        # Check for staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            git_status="${git_status}+"
        fi

        # Check for untracked files
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            git_status="${git_status}?"
        fi

        # Check if ahead/behind remote
        local ahead_behind="$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"
        if [[ "$ahead_behind" =~ ^[0-9]+[[:space:]]+[0-9]+$ ]]; then
            local behind=$(echo "$ahead_behind" | cut -f1)
            local ahead=$(echo "$ahead_behind" | cut -f2)
            if [ "$ahead" -gt 0 ]; then
                git_status="${git_status}↑${ahead}"
            fi
            if [ "$behind" -gt 0 ]; then
                git_status="${git_status}↓${behind}"
            fi
        fi

        if [ -n "$git_status" ]; then
            echo " [$git_status]"
        fi
    fi
}

# Enhanced prompt with Git info
PS1='\[\033[0;36m\]┌──(\[\033[0;34m\]\u\[\033[0;36m\]@\[\033[0;34m\]\h\[\033[0;36m\])-[\[\033[0;37m\]\w\[\033[0;36m\]]\[\033[0;33m\]$(parse_git_branch)\[\033[0;31m\]$(parse_git_status)\[\033[0m\]\n\[\033[0;36m\]└─\[\033[0;34m\]$\[\033[0m\] '

#PS1='\[\033[0;36m\]┌──(\[\033[0;31m\]\u\[\033[0;36m\]@\[\033[0;31m\]\h\[\033[0;36m\])-[\[\033[0;37m\]\w\[\033[0;36m\]]\[\033[0;33m\]$(parse_git_branch)\[\033[0;31m\]$(parse_git_status)\[\033[0m\]\n\[\033[0;36m\]└─\[\033[0;31m\]$\[\033[0m\] '

PROMPT_COMMAND='echo'

# adding colour with man pages.
export LESS_TERMCAP_mb=$'\e[1;95m'    # bright magenta for blinking text
export LESS_TERMCAP_md=$'\e[1;96m'    # bright cyan for bold text (headings)
export LESS_TERMCAP_me=$'\e[0m'       # end mode
export LESS_TERMCAP_so=$'\e[1;33;40m' # yellow on black for standout (status line)
export LESS_TERMCAP_se=$'\e[0m'       # end standout
export LESS_TERMCAP_us=$'\e[1;32m'    # bright green for underlines
export LESS_TERMCAP_ue=$'\e[0m'       # end underline
export LESS_TERMCAP_mr=$'\e[1;91m'    # bright red for reverse
export LESS_TERMCAP_mh=$'\e[2m'       # dim

# This is to add auto completion to my terminal.
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

export PATH="$HOME/.cargo/bin:$PATH"

# File in Present dir auto-completion.

# 🧠 Disable history-based completion
# unset HISTFILE
#
# # 🗂️ Prioritize file and directory completion only
# bind 'set show-all-if-ambiguous on'
# bind 'set menu-complete-display-prefix on'
# bind 'set skip-completed-text on'
#
# # 🧽 Remove all custom completions
# complete -r
# # 📁 Enable default file/directory completion
# complete -o default -f -d

# ===========[ESP32 stuff]=============================================
# >>> ESP Rust environment setup >>>
if [ -f "$HOME/export-esp.sh" ]; then
    source "$HOME/export-esp.sh"
fi
# <<< ESP Rust environment setup <<<
