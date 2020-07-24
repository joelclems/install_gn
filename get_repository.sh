# Ce script permet de cloner les depot
# si le repertoire existe déjà, il ne fait rien 
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_org : l'organisation du depot demande (ex: PNX-SI)
# - $3 repo_name : le depot demandé (ex: UsersHub)
# - $4 repo_branch : la branche ou tag demandé

set -x 
set -e

install_dir=$1
repo_org=$2
repo_name=$3
repo_branch=$4

# test arguments
[ -z "$repo_branch" ] && echo "get_repo : il manque un ou plusieurs arguments" && exit 1;

# adresse depot 
repo_url=https://github.com/$repo_org/$repo_name.git

echo $install_dir/$repo_name

# si le repertoire existe, on ne fait rien 
if [ ! -d $install_dir/$repo_name ]
then 
    git clone $repo_url $install_dir/$repo_name -b $repo_branch
    path_cur=$(pwd)

# sinon clone le depot
else
    echo "Le depot $repo_org/$repo_name est déjà cloné"
    cd $install_dir/$repo_name
    git co master
    git pull
    git co $repo_branch
    cd $path_cur
fi



