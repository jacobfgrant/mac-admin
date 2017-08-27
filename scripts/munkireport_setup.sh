#!/bin/bash
#
# Sets up Munkireport on a
# a new Ubuntu 16.04 Server.
#
# Written by: Jacob F. Grant
# Written: 02/19/2017
# Updated: 06/24/2017
#

# Set variables
MR_SQL_PASSWORD='munkireportmysqlpassword' 


# Installing required updates/software:
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y nginx php7.0-fpm php7.0-mysql php7.0-xml #php7.0-ldap
# Note: php7.0-ldap only necessary if binding to AD/LDAP


# Install MySQL & run installation script:
sudo apt-get install -y mysql-client mysql-server
sudo mysql_secure_installation


# Create munkireport database:
echo
echo 'Enter MySQL root password to create munkireport MySQL user/database'
echo \
"CREATE DATABASE munkireport CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'munkireport_user'@'localhost' IDENTIFIED BY '$MR_SQL_PASSWORD';
GRANT ALL PRIVILEGES ON munkireport.* TO 'munkireport_user'@'localhost' IDENTIFIED BY '$MR_SQL_PASSWORD';
FLUSH PRIVILEGES;" \
| mysql -u root -p


# Modify cgi.fix_pathinfo in php.ini:
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini


# Install munkireport:
sudo git clone https://github.com/munkireport/munkireport-php /usr/share/nginx/html/munkireport
sudo ln -s /usr/share/nginx/html/munkireport ~/munkireport


# Set up config.php:
sudo bash -c "cat > /usr/share/nginx/html/munkireport/config.php" << EOF
<?php if ( ! defined( 'KISS' ) ) exit;

/*
|===============================================
| MunkiReport Server Configuration
|===============================================
| Visit https://github.com/munkireport/munkireport-php/wiki/Server-Configuration for more information on configuration options
*/
\$conf['index_page'] = 'index.php?';
\$conf['sitename'] = 'MunkiReport';
\$conf['allow_migrations'] = FALSE;
\$conf['debug'] = TRUE;
\$conf['timezone'] = @date_default_timezone_get(America/Los_Angles); //your time zone see http://php.net/manual/en/timezones.php
\$conf['vnc_link'] = "vnc://%s:5900";
\$conf['ssh_link'] = "ssh://ladmin@%s";
ini_set('session.cookie_lifetime', 43200);
\$conf['locale'] = 'en_US';
\$conf['lang'] = 'en';
\$conf['temperature_unit'] = 'F';
\$conf['disk_thresholds'] = array('danger' => 25, 'warning' => 100);
\$conf['keep_previous_displays'] = TRUE;

// Require HTTPS
//\$conf['auth_secure'] = TRUE;

/*
|===============================================
| Authorized Users of Munki Report
|===============================================
| Visit http://yourserver.example.com/munkireport/index.php?/auth/generate to generate additional local values
*/
\$auth_config['root'] = '\$P\$BUqxGuzR2VfbSvOtjxlwsHTLIMTmuw0'; // Password is root

// MunkiReport Admins
//\$conf['roles']['admin'] = array();

// MunkiReport Users
//\$conf['roles']['user'] = array();

// Client Secret Passphrase
//\$conf['client_passphrases'] = array();

/*
|===============================================
| PDO Datasource
|===============================================
*/
\$conf['pdo_dsn'] = 'mysql:host=localhost;dbname=munkireport';
\$conf['pdo_user'] = 'munkireport_user';
\$conf['pdo_pass'] = '${MR_SQL_PASSWORD}';
\$conf['pdo_opts'] = array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8');
EOF


# Get IP address
ipaddr=$(ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')


# Configure nginx:
sudo bash -c "cat > /etc/nginx/sites-available/munkireport" << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name ${ipaddr}; # Change this to your Munkireport FQDN

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location /munkireport {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

}
EOF


# Configure nginx server block symlinks
sudo ln -s /etc/nginx/sites-available/munkireport /etc/nginx/sites-enabled/munkireport
sudo rm /etc/nginx/sites-enabled/default


# Modify nginx.conf:
sudo sed -i 's:default_type application/octet-stream;:#default_type application/octet-stream;:' /etc/nginx/nginx.conf


# Restart services
sudo systemctl restart nginx
sudo systemctl restart php7.0-fpm
