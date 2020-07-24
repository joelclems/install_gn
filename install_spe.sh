# installation specifique a chaque depot
#
# entrees
#
# - $1 install_dir : le repertoire d'installation des application
# - $2 repo_name : le depot demandé (ex: UsersHub)


install_dir=$1
repo_name=$2

. settings.ini

path_cur=$(pwd)


echo $install_dir $repo_name
if [ "$repo_name" = "TaxHub" ]
 then 

 echo install TaxHub
. init_config.sh $install_dir/$repo_name/

cd $install_dir/$repo_name
./install_db.sh
./install_app.sh
cd $path_cur

elif [ "$repo_name" = "UsersHub" ]
then
  echo install UH
. init_config.sh $install_dir/$repo_name/config/


cd $install_dir/$repo_name
./install_db.sh
./install_app.sh
cd $path_cur

elif [ "$repo_name" = "GeoNature" ]
then
  echo install GN
. init_config.sh $install_dir/$repo_name/config/

fi
