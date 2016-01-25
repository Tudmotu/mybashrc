# Version Cotrol PS1 Helpers
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)

__hg_branch() {
    hg_branch=$(hg branch 2> /dev/null | awk '{print $1}')
    if [[ -n $hg_branch ]]; then
        hg_root=$(basename $(hg root))
        echo "$hg_root/$hg_branch"
    fi
}
__git_branch() {
    # Based on: http://stackoverflow.com/questions/1593051/
    branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
    branch_name="(detached at $(git rev-parse --short HEAD 2>/dev/null))" ||
    branch_name=""
    branch_name=${branch_name##refs/heads/}
    if [[ -n $branch_name ]]; then
        git_root=$(basename $(git rev-parse --show-toplevel))
        echo "$git_root/$branch_name"
    fi
}
# SVN branch
# Based on:  http://hocuspokus.net/2009/07/add-git-and-svn-branch-to-bash-prompt/
__svn_branch() {
    avn_root=$(__parse_svn_repository_root)
    SVN_PATH="$( __parse_svn_url | sed -e \
        's#^'"$svn_root"'##g' | \
        awk '{print $1}' )"
    SVN_BRANCH=$( echo $SVN_PATH | sed -e "s/.*\/branches\///" )

    if [[ -n $SVN_BRANCH ]]; then
        echo "$svn_root/${SVN_BRANCH%%/*}" | awk '{print $1}'
    fi
}
__parse_svn_url() {
    svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
__parse_svn_repository_root() {
    svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}
__set_prompt() {
    local git_branch=$(__git_branch)
    local hg_branch=$(__hg_branch)
    local svn_branch=$(__svn_branch)
    local bra="\[$WHITE\][\[$RESET\]"
    local ket="\[$WHITE\]]\[$RESET\]"
    local vcs_name=""
    local vcs_branch=""
    local prompt_line=""

    # Add virtual env
    if [[ $VIRTUAL_ENV != "" ]]; then
        prompt_line+="$bra\[$PURPLE\]${VIRTUAL_ENV##*/}$ket"
    fi

    # Add RVM
    if hash rvm-prompt 2>/dev/null; then
        if [[ $(rvm-prompt) != "" ]]; then
            local rvm_prompt=$(rvm-prompt)
            prompt_line+="$bra\[$RED\]${rvm_prompt##*@}$ket"
        fi
    fi

    # Add VCS branches
    if [[ -n $git_branch ]]; then
        vcs_name="git"
        vcs_branch=$(__git_branch)

    elif [[ -n $hg_branch ]]; then
        vcs_name="hg"
        vcs_branch=$(__hg_branch)

    elif [[ -n $svn_branch ]]; then
        vcs_name="svn"
        vcs_branch=$(__svn_branch)
    fi
    if [[ -n $vcs_name ]]; then
        prompt_line+="$bra\[$CYAN\]$vcs_name\[$WHITE\]::\[$RED\]$vcs_branch\[$RESET\]$ket"
    fi

    # Add time
    prompt_line+="$bra\[$GREEN\]\t\[$RESET\]$ket"

    # Add parent directory
    prompt_line+="$bra\[$BLUE\]$(dirname $PWD)/\[$RESET\]$ket"

    # Add user@dir
    prompt_line+="\n\[$CYAN\]\u\[$YELLOW\]@\[$BLUE\]\W\[$RESET\]"

    # Export
    export PS1="$prompt_line \[$GREEN\]\$\[$RESET\] "
}

PROMPT_COMMAND=__set_prompt
