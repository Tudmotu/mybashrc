#
# ~/.bashrc
#
export EDITOR="vim";
export TERM="xterm-256color"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Open tab in same directory
[[ -s "/etc/profile.d/vte.sh"  ]] && . "/etc/profile.d/vte.sh"

# Imports
source ~/.bash/prompt.sh
source ~/.bash/virtenv.sh
source ~/.bash/projects.sh
source ~/.bash/tmuxinator.sh
source ~/.bash/aliases.sh
source ~/.bash/rvm.sh

# Local overrides
if [[ -e ~/.bash/bashrc.local ]]; then
    source ~/.bash/bashrc.local
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

export NVM_DIR="/home/$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
