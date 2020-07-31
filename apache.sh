# DESC: set apache config for repository
# ARGS: $1: install_dir
#       $2: repo_name
# OUTS: None
function setApacheConfig() {
    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required argument to setApacheConfig()!' 2
    fi
    
    install_dir=$1
    repo_name=$2

    getRepositoryOptions ${repo_name}

    rm -f /tmp/conf_apache

    if ! [[ "UsersHub TaxHub GeoNature-atlas GeoNature" == *"$repo_dash_name"* ]]; then 
        return 0
    fi

    # get gun_port
    repo_config_dir_abs=${install_dir}/${repo_dash_name}/${repo_config_dir}
    source ${repo_config_dir_abs}/settings.ini

    echo " - set config apache for ${repo_dash_name}"

    # ajout de ServerName localhost s'il n'est pas déjà présent
    if [ -z "$(grep "ServerName localhost" /etc/apache2/apache2.conf)" ]; then 
        sudo apt-get install -y apache2 libapache2-mod-python libapache2-mod-wsgi
        sudo sh -c 'echo "ServerName localhost" >> /etc/apache2/apache2.conf'
        sudo a2enmod rewrite
        sudo a2dismod python
        sudo a2enmod wsgi
        sudo apache2ctl restart
    fi

    if [ "$repo_dash_name" = "GeoNature" ]; then
        cat << EOF >> /tmp/conf_apache
# Configuration ${repo_dash_name}
Alias /${repo_alias} ${install_dir}/${repo_dash_name}/frontend/dist
<Directory ${install_dir}/${repo_dash_name}/frontend/dist>
Require all granted
</Directory>
<Location /${repo_alias}/api>
ProxyPass http://127.0.0.1:${gun_port}
ProxyPassReverse  http://127.0.0.1:${gun_port}
</Location>
#FIN Configuration ${repo_dash_name}
EOF

    elif [[ "UsersHub TaxHub GeoNature-atlas" == *"${repo_dash_name}"* ]]; then 
        cat << EOF >> /tmp/conf_apache
# Configuration ${repo_dash_name}
<Location /${repo_alias}>
ProxyPass  http://127.0.0.1:${gun_port} retry=0
ProxyPassReverse  http://127.0.0.1:${gun_port}
</Location>
#FIN Configuration ${repo_dash_name}
EOF
    fi

    if [ -f /tmp/conf_apache ]; then
    echo alias ${repo_alias}
        sudo cp /tmp/conf_apache /etc/apache2/sites-available/${repo_alias}.conf
        rm -f /tmp/conf_apache
        sudo a2ensite ${repo_alias}
        sudo a2enmod proxy
        sudo a2enmod proxy_http
    fi

}