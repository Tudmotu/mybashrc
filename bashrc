#
# ~/.bashrc
#
export EDITOR="vim";

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Version Cotrol PS1 Helpers
__hg_branch() {
    hg branch 2> /dev/null | \
        awk '{print $1}'
}
__git_branch() {
    git branch 2> /dev/null | \
        awk '{print $2}'
}
# SVN branch
# Based on:  http://hocuspokus.net/2009/07/add-git-and-svn-branch-to-bash-prompt/
__svn_branch() {
    SVN_PATH="$( __parse_svn_url | sed -e \
        's#^'"$(__parse_svn_repository_root)"'##g' | \
        awk '{print $1}' )"
    SVN_BRANCH=$( echo $SVN_PATH | sed -e "s/.*\/branches\///" )

    if [[ -n $SVN_BRANCH ]]; then
        echo ${SVN_BRANCH%/*} | awk '{print $1}'
    fi
}
__parse_svn_url() {
    svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
__parse_svn_repository_root() {
    svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}

__set_prompt() {
    local BLACK=$(tput setaf 0)
    local RED=$(tput setaf 1)
    local GREEN=$(tput setaf 2)
    local YELLOW=$(tput setaf 3)
    local BLUE=$(tput setaf 4)
    local PURPLE=$(tput setaf 5)
    local CYAN=$(tput setaf 6)
    local WHITE=$(tput setaf 7)
    local RESET=$(tput sgr0)
    local BOLD=$(tput bold)
    local DIM=$(tput dim)
    local git_branch=$(__git_branch)
    local hg_branch=$(__hg_branch)
    local svn_branch=$(__svn_branch)
    local prompt_line="";

    if [[ -n $git_branch ]]; then
        prompt_line="$prompt_line(git::\[$RED\]$git_branch\[$RESET\])"
    fi
    if [[ -n $hg_branch ]]; then
        prompt_line="$prompt_line(hg::\[$RED\]$hg_branch\[$RESET\])"
    fi
    if [[ -n $svn_branch ]]; then
        prompt_line="$prompt_line(svn::\[$RED\]$svn_branch\[$RESET\])"
    fi

    prompt_line="$prompt_line\[$GREEN\]|\$(date +%k:%M:%S)|\
\[$CYAN\]\u\[$YELLOW\]@\[$BLUE\]\w \[$RESET\]\[$GREEN\]\$\[$RESET\] "
    PS1=$prompt_line
}
__set_prompt

# Directory for virtual environments
ENVS_DIR=~/virtualenvs

virtenv() {
    # Messages
    declare -A MSGS;
    MSGS["usage"]=$"Usage: $FUNCNAME [--VERB] [OPTIONS]\nActivate env: $FUNCNAME [ENV-NAME]"
    MSGS["invalid"]="Invalid arguments."
    MSGS["-c"]="Usage: $FUNCNAME $1 <version> <env-name>"
    MSGS["-r"]="Usage: $FUNCNAME $1 <env-name>"
    MSGS["no-such-env"]="No such virtualenv - "
    MSGS["-r-success"]="virtualenv '$2' deleted"

    case "$1" in
        "--list" | "-l")
            for i in $(ls -d $ENVS_DIR/*/);
            do
                echo $i | sed -e 's/.*\/\(\w\+\)\/$/\1/';
            done
            ;;
        "--remove" | "-r")
            if [[ -z $2 ]]; then
                echo ${MSGS["-r"]};
                return;
            elif [[ -d $ENVS_DIR/$2/ ]]; then
                rm -rf $ENVS_DIR/$2/;
                echo ${MSGS["-r-success"]};
            else
                echo ${MSGS["no-such-env"]} $2;
            fi
            ;;
        "--create" | "-c")
            if [[ -z $2 ]] || [[ -z $3 ]]; then
                echo ${MSGS["-c"]};
            else
                case "$2" in
                    "2")
                        virtualenv2 $ENVS_DIR/$3;
                        ;;
                    "3")
                        if hash pyvenv-3.3 2>/dev/null; then
                            pyvenv-3.3 $ENVS_DIR/$3;
                        else
                            virtualenv3 $ENVS_DIR/$3;
                        fi
                        ;;
                esac
            fi
            ;;
        *)
            if [[ -n $1 && -d $ENVS_DIR/$1/ ]]; then
                source $ENVS_DIR/$1/bin/activate;
                return 0;
            elif [[ -n $1 ]]; then
                echo ${MSGS["no-such-env"]} $1;
                return 3;
            fi

            echo ${MSGS["invalid"]};
            echo -e ${MSGS["usage"]};
            return 3;
            ;;
    esac

}
_virtenv_completion() {
    COMPREPLY=()
    local word
    local completions
    word="${COMP_WORDS[COMP_CWORD]}"

    if [[ $COMP_CWORD == 1 ]]; then
        completions=$( for i in $(ls -d $ENVS_DIR/*/); do basename $i; done )
    else
        completions=()
    fi

    COMPREPLY=( $(compgen -W "$completions" -- "$word")  )
}
complete -F _virtenv_completion virtenv;

PROJECTS_DIR=~/MyProjects
project() {
    case "$1" in
        "--create" | "-c")
            if [[ -n $2 ]]; then
                mkdir $PROJECTS_DIR/$2
                echo 'Created ' $2
                project $2
            fi
            ;;
        *)
            PROJECT_DIR=$PROJECTS_DIR/$1
            echo "$PROJECT_DIR";
            ls -la "$PROJECT_DIR";
            cd "$PROJECT_DIR";
            ;;

    esac
}
_project_completion() {
    COMPREPLY=()
    local word
    local completions
    word="${COMP_WORDS[COMP_CWORD]}"

    if [[ $COMP_CWORD == 1 ]]; then
        completions=$( for i in $(ls -d $PROJECTS_DIR/*/); do basename $i; done )
    else
        completions=()
    fi

    COMPREPLY=( $(compgen -W "$completions" -- "$word")  )
}
complete -F _project_completion project;

# Aliases:
alias 'lsa'='ls -la --color=auto'
alias 'ls'='ls --color=auto'
alias 'bashrc'='vim ~/.bash/bashrc'

# Local overrides
if [[ -e ~/.bash/bashrc.local ]]; then
    source ~/.bash/bashrc.local
fi

