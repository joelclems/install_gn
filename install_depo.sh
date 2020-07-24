# installation d'un depot
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_org : l'organisation du depot demande (ex: PNX-SI)
# - $3 repo_name : le depot demandé (ex: UsersHub)
# - $4 repo_branch : la branche ou tag demandé (ex: UsersHub)


set -x
set -e

install_dir=$1
repo_org=$2
repo_name=$3
repo_branch=$4

echo Install $repo_org/$repo_name

[ -z $repo_branch ] && echo "install $repo_name : pb parametres" && exit 1

# test si le depot est present dans ./installed.txt dans ce cas on ne fait rien
grep "${repo_name} ${repo_branch}" ./installed.txt && echo "install $repo_org/$repo_name : L'application est déjà installée" && exit 1

# clonage si besoin du depot
./get_repository.sh $install_dir $repo_org $repo_name $repo_branch

# configuration et installation du depot 
./install_spe.sh $install_dir $repo_name

[ -z "$(grep $repo_name ./installed.txt)" ] && echo "${repo_name} ${repo_branch}" >> ./installed.txt