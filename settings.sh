# DESC: check settings.ini file and set environnent variables
# ARGS: $1 path to settings.ini
#       $2 path to repositories.ini
# OUTS: None
processSettings() {
    
    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument (2)to processSettings' 2
    fi

    settings_file=$1
    repositories_file=$2

    # test if settings.ini exists
    if [ ! -f  ${settings_file} ]; then 
        exitScript "File ${settings_file} does not exist. You can create it from ${settings_file}.sample" 2
    fi

    # test if repository.ini exists
    if [ ! -f  ${repositories_file} ]; then 
        exitScript "File ${repositories_file} does not exists" 2
    fi


    # test if settings.ini is set (no xxx remaining)
    if [ ! -z $(grep xxx ${settings_file}) ]; then 
        exitScript "File ${settings_file} is not set"
    fi

    source ${repositories_file}
    source ${settings_file}

    #PATCH Users-Hub
    pg_port=${db_port}
    url_application=${my_url}usershub

    # PATCH GeoNature-Atlas
    owner_atlas=${user_pg}
    owner_atlas_pass=${user_pg_pass}
    db_source_host=${db_host}
    db_source_port=${db_port}
    db_source_name=${db_name}
    atlas_source_user=${user_pg}
    atlas_source_pass=${user_pg_pass}

    patch_vars="pg_port url_application owner_atlas owner_atlas_pass db_source_host db_source_port db_source_name atlas_source_user atlas_source_pass"

    settings_vars="$(cat ${repositories_file} ${settings_file} | sed '/^#/d' | grep = | cut -d = -f1) ${patch_vars}" 

    echo $pg_port
    # set variable from repositories.ini and settings.ini to global
    for var in ${settings_vars}; do
        # pour les variable en options
        var_arg="$(getValue ${var}_arg)"
        if [ ! -z "${var_arg}" ]; then
          eval "${var}=\"${var_arg}\""
        fi
        export $var
    done
    
    export $settings_vars
}