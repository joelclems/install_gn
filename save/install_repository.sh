# installation d'un depot
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_name : le depot demandé (ex: UsersHub)

[ "$install_debug" = "1" ] && set -x
set -e

install_dir=$1
repo_name=$2

echo Install $repo_org/$repo_name

[ -z $repo_name ] && echo "install $repo_name : pb parametres" && exit 1

repo_org_var_name=${repo_name}_org
repo_org=${!repo_org_var_name}

repo_branch_var_name=${repo_name}_branch
repo_branch=${!repo_branch_var_name}
repo_install_dir_var_name=${repo_name}_install_dir
repo_install_dir=${!repo_install_dir_var_name}


# test si le depot est present dans ./installed.txt dans ce cas on ne fait rien
grep "${repo_name} ${repo_branch}" ./installed.txt && echo "install $repo_org/$repo_name : L'application est déjà installée" && exit 0

# clonage si besoin du depot
./get_repository.sh $install_dir $repo_name

# configuration et installation du depot
 echo install $depo_name
. init_config.sh $install_dir $repo_name

path_cur=$(pwd)

cd $install_dir/$repo_name/$repo_install_dir
[ -f ./install_env.sh ] && ./instal_env.sh
[ -f ./install_db.sh ] && ./install_db.sh
[ -f ./install_app.sh ] && ./install_app.sh
cd $path_cur

./apache.sh $install_dir $repo_name

[ -z "$(grep $repo_name ./installed.txt)" ] && echo "${repo_name} ${repo_branch}" >> ./installed.txt