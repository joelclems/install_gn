# Ce script permet de cloner les depot
# si le repertoire existe déjà, il ne fait rien 
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_name : le depot demandé (ex: UsersHub)

[ "$install_debug" = "1" ] && set -x
set -e

install_dir=$1
repo_name=$2

repo_branch_var_name=${repo_name}_branch
repo_branch=${!repo_branch_var_name}
repo_org_var_name=${repo_name}_org
repo_org=${!repo_org_var_name}

# test arguments
[ -z "$repo_name" ] && echo "get_repo :il manque des arguments" && exit 1;

# adresse depot 
repo_url=https://github.com/$repo_org/$repo_name.git

# si le repertoire n'est pas existe, on clone le depot 
if [ ! -d $install_dir/$repo_name ]
then 
    git clone $repo_url $install_dir/$repo_name -b $repo_branch
    path_cur=$(pwd)

# sinon pull et co sur la branche
else
    echo "Le depot $repo_org/$repo_name est déjà cloné"
    cd $install_dir/$repo_name
    git co master
    git pull
    git co $repo_branch
    cd $path_cur
fi



