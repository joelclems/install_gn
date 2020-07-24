# ce script permet d'initialiser le fichier settings.ini du depôt a partir du fichier settings.ini de ce repertoire
#
# entrees
#
# $1 config_dir : le chemin vers le repertoire du depot qui contient le fichier settings.ini

set -x

. settings.ini

config_dir=$1

[ ! -d $config_dir ] && echo init_config le repertoire est mal renseigné $config_dir && exit 1

# - config
rm -f config.py
cp $config_dir/settings.ini.sample $config_dir/settings.ini
for var in \
db_host \
db_port \
db_name \
user_pg \
user_pg_pass
do  
    sed -i -e "s/^${var}=.*/${var}=${!var}/" $config_dir/settings.ini   
done

# PATCH GN
sed -i -e "s|^my_url=.*|my_url=${my_url}|" $config_dir/settings.ini   


# patch UH
sed -i -e "s/^pg_port=.*/pg_port=${db_port}/" $config_dir/settings.ini   


cat $config_dir/settings.ini | grep my_url