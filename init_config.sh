# ce script permet d'initialiser le fichier settings.ini du depôt a partir du fichier settings.ini de ce repertoire
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_name : le depot demandé (ex: UsersHub)

[ "$install_debug" = "1" ] && set -x
set -e

install_dir=$1
repo_name=$2

[ -z $repo_name ] && echo init_config pb_arguments && exit 1

#PATCH UH
pg_port=$db_port
url_application=${my_url}usershub
list_var_patch="pg_port url_application"


repo_config_dir_var_name=${repo_name}_config_dir
repo_config_dir=${!repo_config_dir_var_name}

abs_config_dir=$install_dir/$repo_name/$repo_config_dir

rm -f $abs_config_dir/config.py
cp $abs_config_dir/settings.ini.sample $abs_config_dir/settings.ini
for var in $(grep = ./settings.ini | cut -d = -f1) ${list_var_patch}
do  
    echo $var
    sed -i -e "s|^${var}=.*|${var}=${!var}|" $abs_config_dir/settings.ini   
done
cat $abs_config_dir/settings.ini