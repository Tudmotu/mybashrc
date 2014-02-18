#
# ~/.bashrc
#
export EDITOR="vim";

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Open tab in same directory
[[ -s "/etc/profile.d/vte.sh"  ]] && . "/etc/profile.d/vte.sh"

# Imports
source ~/.bash/prompt.sh
source ~/.bash/virtenv.sh
source ~/.bash/projects.sh
source ~/.bash/aliases.sh

# Local overrides
if [[ -e ~/.bash/bashrc.local ]]; then
    source ~/.bash/bashrc.local
fi

