#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# If on TTY1, start Hyprland
if [[ "$(tty)" == "/dev/tty1" ]]; then
    exec Hyprland &>/dev/null
fi

export SYSTEMD_EDIT=nvim
export EDITOR=nvim
export VISUAL="$EDITOR"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"

# fastfetch
