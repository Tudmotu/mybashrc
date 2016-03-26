PROJECTS_DIR=~/MyProjects
project() {
    case "$1" in
        "--create" | "-c")
            if [[ -n $2 ]]; then
                mkdir -p $PROJECTS_DIR/$2
                echo 'Created ' $2
                project $2
            fi
            ;;
        "--git")
            if [[ -n $2 ]]; then
                cd $PROJECTS_DIR
                dir_name='default'
                if [[ -n $3 ]]; then
                    dir_name=$3
                else
                    dir_name=`expr match $2 '.*\/\(.*\)\.git'`
                fi
                git clone $2 $dir_name
                project $dir_name
            else
                echo 'You must supply a URL when creating a project from Git'
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

