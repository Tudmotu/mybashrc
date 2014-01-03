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
