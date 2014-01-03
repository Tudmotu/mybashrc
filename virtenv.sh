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
