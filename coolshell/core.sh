#### README ####
# make your own exports, aliases, functions and add.. files, all based on your needs.

#### Core Settings ####
# the directore of it
COOLSHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

# Exit if not running interactively
[[ $- != *i* ]] && return

# Disable core dumps
ulimit -c 0

# Basic ls coloring
alias ls='ls --color=auto'

# Custom prompt - [current_directory] >
PS1='[\u@\h][\W] > '
#PS1='[\W] > '  # W for basename only, w for full path


#### Core Aliases ####
alias ll='ls -lhGF'
alias lla='ls -lhGFA'
alias rm='trash'
alias rmm='/bin/rm'
alias n='nvim'
alias p3='python3'
alias t='tmux'


#### Core Functions ####
# Mount drive with notification
m() {
  udisksctl mount -b /dev/"$1" && notify-send "HDD Mounted"
}

# Unmount drive with notification
um() {
  udisksctl unmount -b /dev/"$1" && notify-send "HDD Unmounted"
}

# Run command in background (detached)
o() {
    nohup "$@" </dev/null &>/dev/null & disown
}


#### Core Addons ####
alias hello='figlet "Welcome Back" | toilet -F metal -f term'
alias goodbye='figlet "Good Bye" | toilet -F metal -f term'
alias loveyou='figlet "I Love You" | toilet -F metal -f term'


