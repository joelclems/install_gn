# script principal
# lance l'installation des applis
# la configuration est définie dans le ficher settings.ini
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application

set -x

[ ! -f ./settings.ini ] && echo "Veuillez copier et renseigner le fichier settings.ini"

. ./settings.ini

install_dir=$1

[ ! -d $install_dir ] && echo "install_all : Le repertoire d'installation n'est pas specifié" && exit 1;

# creation au besoin du repertoire d'installation
mkdir -p $install_dir

# creation du fichier qui dit si un depot est installé
[ ! -f ./installed.txt ] && touch ./installed.txt

echo depots $depots

# installation des depots
for depot_name in ${depots}
do 
depot_org_var_name=${depot_name}_org
depot_branch_var_name=${depot_name}_branch
./install_depo.sh $install_dir ${!depot_org_var_name} $depot_name ${!depot_branch_var_name}
done

