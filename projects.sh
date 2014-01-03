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

