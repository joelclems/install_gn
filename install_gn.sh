#!/usr/bin/env bash
# Encoding : UTF-8
# Migrate GeoNature from v2.1.2 to v2.4.0
#
# Documentation : https://github.com/joelclems/install_gn
set -eo pipefail

# DESC: Usage help
# ARGS: None
# OUTS: None
function printScriptUsage() {
    cat << EOF
Usage: ./$(basename $BASH_SOURCE)[options]
     -h | --help: display this help
     -v | --verbose: display more infos
     -x | --debug: display debug script infos
     -p | --install_dir: path to installation directory, will be created if not exists
     -d | --depots: redefine depots lists
     -a | --actions: redefine action lists
EOF
    exit 0
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parseScriptOptions() {
    # Transform long options to short ones
    for arg in "${@}"; do
        shift
        case "${arg}" in
            "--help") set -- "${@}" "-h" ;;
            "--verbose") set -- "${@}" "-v" ;;
            "--debug") set -- "${@}" "-x" ;;
            "--install-dir") set -- "${@}" "-p" ;;
            "--depots") set -- "${@}" "-d" ;;
            "--actions") set -- "${@}" "-d" ;;
            "--"*) exitScript "ERROR : parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "hvxp:d:a:" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") echo ii; readonly debug=true; set -x ;;
            "p") install_dir="${OPTARG}" ;;
            "d") depots_arg="${OPTARG}" ;;
            "a") actions="${OPTARG}" ;;
            *) exitScript "ERROR : parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done

    if [ -z ${install_dir} ]; then
        exitScript "Please enter installation directory (option -p or --install-dir) ! Use -h option to know more" 2
    fi 
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
    #+----------------------------------------------------------------------------------------------------------+

    #
    # Initialisation
    #

    # Load functions
    file_names="utils.sh settings.sh repositories.sh apache.sh"
    for file_name in ${file_names}; do
        source "$(dirname "${BASH_SOURCE[0]}")/${file_name}"
    done

    parseScriptOptions "${@}"
    initScript "${@}"

    processSettings ${script_dir}/settings.ini ${script_dir}/repositories.ini

    printPretty "The following repositories will be processed"
    for repo_name in $depots; do
       echo " - $(printRepository $repo_name)"
    done

    for repo_name in $depots; do
       processRepository $install_dir $repo_name
    done
}

main "${@}"