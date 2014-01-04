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
    local git_branch=$(__git_branch)
    local hg_branch=$(__hg_branch)
    local svn_branch=$(__svn_branch)
    local prompt_line="";

    if [[ -n $git_branch ]]; then
        prompt_line+="(\[$CYAN\]git\[$WHITE\]::\[$RED\]$git_branch\[$RESET\])"
    fi
    if [[ -n $hg_branch ]]; then
        prompt_line+="(\[$CYAN\]hg\[$WHITE\]::\[$RED\]$hg_branch\[$RESET\])"
    fi
    if [[ -n $svn_branch ]]; then
        prompt_line+="(\[$CYAN\]svn\[$WHITE\]::\[$RED\]$svn_branch\[$RESET\])"
    fi

    export PS1="$prompt_line\[$GREEN\]|\$(date +%k:%M:%S)|\
\[$CYAN\]\u\[$YELLOW\]@\[$BLUE\]\w \[$RESET\]\[$GREEN\]\$\[$RESET\] "
}

PROMPT_COMMAND=__set_prompt
