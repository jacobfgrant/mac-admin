#!/bin/bash
#
# Sets up a Munkireport on a
# a new Ubuntu 16.04 Server.
#
# Written by: Jacob F. Grant
# Written: 02/19/2017
# Updated: 04/04/2017
#


# Installing required updates/software:
sudo apt-get update
sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
sudo apt-get install -y nginx php7.0-fpm php7.0-mysql php7.0-xml #php7.0-ldap
# Note: php7.0-ldap only necessary if binding to AD/LDAP


# Install MySQL & run installation script:
sudo apt-get install -y mysql-client mysql-server

sudo mysql_secure_installation #--use-default


# Create munkireport database:
echo "CREATE DATABASE munkireport CHARACTER SET utf8 COLLATE utf8_bin;" | mysql -u root -p
#echo "CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';" | mysql -u root -p
echo "CREATE USER 'munkireport_user'@'localhost' IDENTIFIED BY 'munkireport';" | mysql -u root -p
#echo "GRANT ALL PRIVILEGES ON munkireport.* TO 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';" | mysql -u root -p
echo "GRANT ALL PRIVILEGES ON munkireport.* TO 'munkireport_user'@'localhost' IDENTIFIED BY 'hello';" | mysql -u root -p
echo "FLUSH PRIVILEGES;" | mysql -u root -p


# Modify cgi.fix_pathinfo in php.ini:
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini

sudo systemctl restart php7.0-fpm


# Install munkireport:
sudo git clone https://github.com/munkireport/munkireport-php /usr/share/nginx/html/report

sudo ln -s /usr/share/nginx/html/report ~/report


# Set up config.php:
sudo bash -c "cat > /usr/share/nginx/html/report/config.php" << EOF
<?php if ( ! defined( 'KISS' ) ) exit;

\$conf['index_page'] = 'index.php?';
\$conf['sitename'] = 'MunkiReport';
\$conf['allow_migrations'] = FALSE;
\$conf['debug'] = TRUE;
\$conf['timezone'] = @date_default_timezone_get(America/Los_Angles); //your time zone see http://php.net/manual/en/timezones.php
\$conf['vnc_link'] = "vnc://%s:5900";
\$conf['ssh_link'] = "ssh://$USER@%s";
ini_set('session.cookie_lifetime', 43200);
\$conf['locale'] = 'en_US';
\$conf['lang'] = 'en';
\$conf['keep_previous_displays'] = TRUE;

/*
|===============================================
| Authorized Users of Munki Report
|===============================================
| Visit http://yourserver.example.com/report/index.php?/auth/generate to generate additional local values
*/
\$auth_config['root'] = '\$P\$BUqxGuzR2VfbSvOtjxlwsHTLIMTmuw0'; // Password is root

/*
|===============================================
| PDO Datasource
|===============================================
*/
\$conf['pdo_dsn'] = 'mysql:host=localhost;dbname=munkireport';
\$conf['pdo_user'] = 'munkireport_user';
\$conf['pdo_pass'] = 'munkireport';
\$conf['pdo_opts'] = array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8');
EOF


# Backup default nginx config and create our own:
sudo mv /etc/nginx/sites-enabled/default ~/default.bkup


# Configure nginx:
sudo bash -c "cat > /etc/nginx/sites-enabled/default" << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    server_name munki;

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location /report {
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

    location /munki_repo/ {
      alias /usr/local/munki_repo/;
      autoindex off;
      #auth_basic "Restricted";
      #auth_basic_user_file /etc/nginx/.htpasswd;
  }
}
EOF


# Modify nginx.conf:
sudo sed -i 's:default_type application/octet-stream;:#default_type application/octet-stream;:' /etc/nginx/nginx.conf

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php7.0-fpm
