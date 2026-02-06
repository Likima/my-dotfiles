#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export SYSTEMD_EDIT=nvim
export EDITOR=nvim
export VISUAL="$EDITOR"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# kitten icat ~/Pictures/Wallpapers/chunky.gif

fastfetch

eval "$(starship init bash)"
