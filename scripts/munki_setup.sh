#!/bin/bash
#
# Sets up a basic Munki repo on
# a new Ubuntu 16.04 Server.
#
# Written by: Jacob F. Grant
# Written: 08/19/2016
# Updated: 04/04/2017
#


# Installing required updates/software:
sudo apt-get update
sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
sudo apt-get -y install python git curl build-essential nginx apache2-utils samba

# Setup the directories:
sudo mkdir /usr/local/munki_repo
sudo mkdir -p /etc/nginx/sites-enabled
ln -s /usr/local/munki_repo ~/
cd /usr/local/munki_repo
sudo mkdir catalogs client_resources icons manifests pkgs pkgsinfo
#cd

# Creating the service accounts & set directory permissions:
sudo addgroup --system munki
sudo adduser --system munki --ingroup munki
sudo usermod -a -G munki $USER # Adds the current console user to munki group
sudo usermod -a -G munki www-data # Adds web user to munki group
sudo chown -R $USER:munki /usr/local/munki_repo
sudo chmod -R 2774 /usr/local/munki_repo

# Backup default nginx config and create our own:
sudo mv /etc/nginx/sites-enabled/default ~/default.bkup
#sudo nano /etc/nginx/sites-enabled/default
#sudo touch /etc/nginx/sites-enabled/default

# Insert here
ipaddr=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

#cat > /etc/nginx/sites-enabled/default << EOL
sudo bash -c "cat > /etc/nginx/sites-enabled/default" << EOF
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  root /usr/share/nginx/html;
  index index.php index.html index.htm;

  server_name ${ipaddr}; # Change this to your FQDN.

  location /munki_repo/ {
    alias /usr/local/munki_repo/;
    autoindex off;
    #auth_basic "Restricted";
    #auth_basic_user_file /etc/nginx/.htpasswd;
  }
}
EOF

#sudo nano /etc/nginx/sites-enabled/default

# Restart nginx
sudo systemctl start nginx

# Set up samba
sudo smbpasswd -a munki

#cat >> /etc/samba/smb.conf << EOL
sudo bash -c "cat >> /etc/samba/smb.conf" <<EOL
[munki_repo]
path = /usr/local/munki_repo
available = yes
valid users = munki
read only = no
browseable = yes
public = no
writable = yes
EOL

# Restart samba
sudo systemctl restart smbd
