# script principal
# lance l'installation des applis
#
# la configuration est définie dans le ficher settings.ini
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application

# sudo apt-get install -y apache2 libapache2-mod-python libapache2-mod-wsgi

[ "$install_debug" = "1" ] && set -x
set -e

[ ! -f ./settings.ini ] && echo "Veuillez copier et renseigner le fichier settings.ini"

. ./repositories.ini
. ./settings.ini

# on met les variables des fichiers repositories.ini et settings.ini en global
for var in $(cat repositories.ini settings.ini |  grep = | cut -d = -f1)
do
export ${var}
done

[ "$install_debug" = "1" ] && set -x

install_dir=$1

[ -z $install_dir ] && echo "install_all : Le repertoire d'installation n'est pas specifié" && exit 1;

# creation au besoin du repertoire d'installation
mkdir -p $install_dir

# creation du fichier qui dit si un depot est installé
[ ! -f ./installed.txt ] && touch ./installed.txt

echo depots $depots

# installation des depots
for repo_name in ${depots}
do 
./install_repository.sh $install_dir $repo_name
done

