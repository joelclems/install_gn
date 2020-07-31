#+----------------------------------------------------------------------------------------------------------+
# Functions

#################################
# Set env
#################################


# DESC: Generic script initialisation
function initScript() {
    # Script time
    readonly time_start="$(date +%s)"
    readonly fmt_time_start="$(date -d @${time_start} "+%Y-%m-%d %H:%M:%S")"

    # Useful paths
    readonly orig_cwd="$PWD"
    readonly script_path="${BASH_SOURCE[1]}"
    readonly script_dir="$(dirname "$script_path")"
    readonly script_name="$(basename "$script_path")"
    readonly script_params="$*"

    #+----------------------------------------------------------------------------+
    # Directories pathes
    readonly bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    readonly root_dir="$(realpath $bin_dir/..)"
    readonly conf_dir="${root_dir}/config"
    readonly sql_dir="${root_dir}/sql"
    readonly var_dir="${root_dir}/var"
    readonly log_dir="${var_dir}/log"
    readonly tmp_dir="${var_dir}/tmp"

    #+----------------------------------------------------------------------------+
    # Shell colors
    readonly RCol="\e[0m";# Text Reset
    readonly Red="\e[1;31m"; # Text Dark Red
    readonly Gre="\e[1;32m"; # Text Dark Green
    readonly Yel="\e[1;33m"; # Text Yellow
    readonly Mag="\e[1;35m"; # Text Magenta
    readonly Gra="\e[1;30m"; # Text Dark Gray
    readonly Whi="\e[1;37m"; # Text Dark White
    readonly Blink="\e[5m"; #Text blink

    #+----------------------------------------------------------------------------+
    # Section separator
    readonly sep_limit=100
    readonly sep="$(printf "=%.0s" $(seq 1 ${sep_limit}))\n"

    #+----------------------------------------------------------------------------+
    # Important to always set as we use it in the exit handler
    readonly ta_none="$(tput sgr0 2> /dev/null || true)"
}


#################################
# ExitScript
#################################

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
# NOTE: The convention used in this script for exit codes is:
#       0: Normal exit
#       1: Abnormal exit due to external error
#       2: Abnormal exit due to script error
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function exitScript() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "${1}"
        exit 0
    fi

    if [[ ${2-} =~ ^[0-9]+$ ]]; then
        if [[ ${2} -ne 0 ]]; then
            printError "${1}"
        else
            printInfo "${1}"
        fi
        exit ${2}
    fi

    exitScript 'Missing required argument to exitScript()!' 2
}

# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a yellow)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code.
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printPretty() {
    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to printPretty()!' 2
    fi

    if [[ -n ${2-} ]]; then
        echo -e "${2}${1}${RCol}"
    else
        echo -e "${Yel}${1}${RCol}"
    fi
}

# DESC: Print a section message
# ARGS: $1 (required): Message to print
# OUTS: None
function printMsg() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printMsg()!' 2
    fi
    printPretty "--> ${1}" ${Yel}
}

# DESC: Print infos message
# ARGS: $1 (required): Message to print
# OUTS: None
function printInfo() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printInfo()!' 2
    fi
    printPretty "--> ${1}" ${Whi}
}

# DESC: Print an error message
# ARGS: $1 (required): Message to print
# OUTS: None
function printError() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printError()!' 2
    fi
    printPretty "--> ${1}" ${Red}
}

# DESC: Only printPretty() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to printPretty() function
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printVerbose() {
    if [[ -n ${verbose-} ]]; then
        printPretty "${@}"
    fi
}


#################################
# Get value
#################################

# DESC: get value of var whose name is $1_$2 
# ARGS: $1 : first part var name
#       $2 : second part (key) of var name 
# OUTS: var value (echo)
# USAGE: a=$(getValue GeoNature_org)
function getValue() {
    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required arguments (1) to getValue()' 2
    fi

    var_name=$1
    var_value=${!var_name}
    echo $var_value
}