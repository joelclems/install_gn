set -e
[ "$install_debug" = "1" ] && set -x


install_dir=$1
repo_name=$2

alias_var_name=${repo_name}_alias
alias=${!alias_var_name}
repo_config_dir_var_name=${repo_name}_config_dir
repo_config_dir=${!repo_config_dir_var_name}

# pour avoir les ports
. $install_dir/${repo_name}/${repo_config_dir}/settings.ini

[ -z "$repo_name" ] && echo 'install apache pas de repo_name defini' && exit 1

# ajout de ServerName localhost s'il n'est pas déjà présent
if [ -z "$(grep "ServerName localhost" /etc/apache2/apache2.conf)" ]
then 
sudo apt-get install -y apache2 libapache2-mod-python libapache2-mod-wsgi
sudo sh -c 'echo "ServerName localhost" >> /etc/apache2/apache2.conf'
sudo a2enmod rewrite
sudo a2dismod python
sudo a2enmod wsgi
sudo apache2ctl restart
fi

if [ "$repo_name" = "GeoNature" ]
then
cat << EOF >> /tmp/conf_apache
# Configuration $repo_name
Alias /$alias $install_dir/$repo_name/frontend/dist
<Directory $install_dir/$repo_name/frontend/dist>
Require all granted
</Directory>
<Location /$alias/api>
ProxyPass http://127.0.0.1:$gun_port
ProxyPassReverse  http://127.0.0.1:$gun_port
</Location>
#FIN Configuration $repo_name
EOF

elif [ "$repo_name" = "UsersHub" ] || [ "$repo_name" = "TaxHub" ]
then 
cat << EOF >> /tmp/conf_apache
# Configuration $repo_name
<Location /$alias>
ProxyPass  http://127.0.0.1:$gun_port retry=0
ProxyPassReverse  http://127.0.0.1:$gun_port
</Location>
#FIN Configuration $repo_name
EOF
fi

if [ -f /tmp/conf_apache ]
then
sudo cp /tmp/conf_apache /etc/apache2/sites-available/$alias.conf
rm -f /tmp/conf_apache
sudo a2ensite ${alias}
sudo a2enmod proxy
sudo a2enmod proxy_http
fi