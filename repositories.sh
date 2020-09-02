#+----------------------------------------------------------------------------------------------------------+
# Functions pour les depots

#DESC: get repository options
#ARGS: $1: repo_name
#OUTS:  repo_dash_name (PATCH repo_name can not have '-') 
#       repo_org, repo_alias, repo_branch, repo_module, repo_install_dir, repo_ins
function getRepositoryOptions() {

    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to getRepositoryOptions()!' 2
    fi

    repo_name=$1

    repo_dash_name_default=${repo_name}

    var_names="org branch install_dir config_dir dash_name alias module_path"
    for name in ${var_names}; do
        eval "repo_${name}=\"$(getValue ${repo_name}_${name})\""
        if [ -z "$(getValue repo_${name})" ]; then
            eval "repo_${name}=\"$(getValue repo_${name}_default)\""
        fi
    done

    # default values
    if [ -z "${repo_dash_name}" ]; then 
        repo_dash_name="${repo_name}"
    fi
}

#DESC: print repository options
#ARGS: $1: repo_name
#OUTS: repository options
function printRepository() {

    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to printRepository()!' 2
    fi

    repo_name=$1

    getRepositoryOptions ${repo_name}

    echo ${repo_org}/${repo_dash_name} ${repo_branch}
}

# DESC: get repository from github, if directory already exist, exec git pull and set branch
# ARGS: $1: install_dir
#       $2: repo_name
# OUTS: None
function getRepository() {
    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument to getRepository()!' 2
    fi

    install_dir=$1
    repo_name=$2

    getRepositoryOptions ${repo_name}

    # repository url
    repo_url=https://github.com/${repo_org}/${repo_dash_name}.git
    repo_dir=${install_dir}/${repo_dash_name}

    # if directory does not exist : git clone
    if [ ! -d ${repo_dir} ]; then
        echo " - clone repository ${repo_org}/${repo_dash_name} from ${repo_url} and set branch ${repo_branch}"
        echo git clone ${repo_url} ${repo_dir} -b ${repo_branch} -q
        git clone ${repo_url} ${repo_dir} -b ${repo_branch} -q

    # if directory exists : git pull and git co
    else
        echo " - pull repository ${repo_org}/${repo_dash_name} and set branch ${repo_branch}"
        path_cur=$(pwd)
        cd ${repo_dir}
        options="-q"

        git co ${repo_branch} ${options}

        if [ "$(git show-ref --verify refs/heads/${repo_name})" ]
        then  
            git pull ${options}
        fi   

        cd ${path_cur}
    fi
}

# DESC: setRepositoryConfig : set application settings.ini with values contained in settings.ini
# ARGS: $1: install_dir
#       $2: repo_name
# OUTS: None
function setRepositoryConfig() {

    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument to setRepositoryConfig()!' 2
    fi

    getRepositoryOptions ${repo_name}

    if [ ! -z "${repo_module_path}" ]; then 
        return 0
    fi


    install_dir=$1
    repo_name=$2

    repo_config_dir_abs=${install_dir}/${repo_dash_name}/${repo_config_dir}

    echo " - set config ${repo_config_dir_abs}/settings.ini"

    # TODO check this
    rm -f ${repo_config_dir_abs}/config.py

    cp ${repo_config_dir_abs}/settings.ini.sample ${repo_config_dir_abs}/settings.ini

    for var in ${settings_vars}
    do  
        sed -i -e "s|^${var}=.*|${var}=${!var}|" $repo_config_dir_abs/settings.ini    
    done
    
    # PATCH GeoNature-Atlas
    if [ "${repo_dash_name}" = "GeoNature-atlas" ]; then
        sed -i -e "s|^db_name=.*|db_name=${GeoNature_atlas_db_name}|" ${repo_config_dir_abs}/settings.ini    
    fi

    source ${repo_config_dir_abs}/settings.ini
}


# DESC: install env for repository
# ARGS: $1: install_dir
#       $2: repo_name
#       $3: type_install
# OUTS: None
function installGeneric() {

    if [[ $# -lt 3 ]]; then
        exitScript 'Missing required argument to installGeneric()!' 2
    fi
    
    install_dir=$1
    repo_name=$2
    type_install=$3

    getRepositoryOptions ${repo_name}

    path_cur=$(pwd)
    repo_install_dir_abs=${install_dir}/${repo_dash_name}/${repo_install_dir}
    cd $repo_install_dir_abs
    install_file="./install_${type_install}.sh"
    if [ -f ${install_file} ]; then
        echo " - Install ${type_install} for ${repo_name}"
        ${install_file}
    fi
}

# DESC: install env db and app for repository
# ARGS: $1: install_dir
#       $2: repo_name
# OUTS: None
function installRepository() {
    
    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument to installRepository()!' 2
    fi
    
    install_dir=$1
    repo_name=$2

    if [ ! -z "${repo_module_path}" ]; then 
        echo " - Install GeoNature Module ${repo_name}"
        path_cur=$(pwd)

        module_dir=${install_dir}/${repo_dash_name}

        cd $install_dir/GeoNature
        source backend/venv/bin/activate
        geonature install_gn_module $module_dir $repo_module_path

        if [ "${repo_name}" = "gn_module_monitoring" ]; then 
            flask monitorings install $install_dir/gn_module_monitoring/contrib/test test
        fi


    else 
        installGeneric $install_dir $repo_name env
        installGeneric $install_dir $repo_name db
        installGeneric $install_dir $repo_name app
    fi
}   


# DESC test_action
# ARGS: $1 actions
# OUTS: 1 if action
function testAction() {

    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to testAction()!' 2
    fi

    action=$1

    if [ -z "${actions}" ]; then 
        return 0
    elif [[ "${actions}" == *"$action"* ]]; then
        return 0
    else 
        return 1
    fi
}

# DESC: process ths followings steps for a repository 
#       - get repository
#       - set config
#       - install env db app
#       - set apache config
# ARGS: $1: install_dir
#       $2: repo_name
# OUTS: None
function processRepository() {

    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument to processRepository()!' 2
    fi

    install_dir=$1
    repo_name=$2

    getRepositoryOptions ${repo_name}

    printPretty "Process Repository $(printRepository $repo_name)"

    getRepositoryOptions $repo_name
    testAction GET_REPO &&  getRepository $install_dir $repo_name
    setRepositoryConfig $install_dir $repo_name
    testAction INSTALL &&  installRepository $install_dir $repo_name
    testAction APACHE &&  setApacheConfig $install_dir $repo_name
}
