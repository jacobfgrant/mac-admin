#!/bin/bash
#
#  Sets up a basic Munki repo on
#  a new Ubuntu 16.04 Server.
#
#  Created by Jacob F. Grant
#
#  Written: 08/19/2016
#  Updated: 06/24/2017
#

# Installing required updates/software:
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install apache2-utils build-essential curl git nginx python samba


# Setup the directories:
sudo mkdir /srv/munki_repo
ln -s /srv/munki_repo ~/
cd /srv/munki_repo
sudo mkdir catalogs client_resources icons manifests pkgs pkgsinfo
cd


# Creating the service accounts & set directory permissions:
sudo addgroup --system munki
sudo adduser --system munki --ingroup munki --no-create-home
sudo usermod -aG munki $USER # Adds the current console user to munki group
sudo usermod -aG munki www-data # Adds web user to munki group
sudo chown -R munki:munki /srv/munki_repo
sudo chmod -R 2774 /srv/munki_repo


# Get IP address
ipaddr=$(ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')


#cat > /etc/nginx/sites-enabled/default << EOL
sudo bash -c "cat > /etc/nginx/sites-available/munki" << EOF
server {
  listen 80 default_server;
  listen [::]:80 default_server;

  server_name ${ipaddr}; # Change this to your Munki FQDN

  root /usr/share/nginx/html;
  index index.php index.html index.htm;

  location /munki_repo/ {
    alias /srv/munki_repo/;
    autoindex off;
    #auth_basic "Restricted";
    #auth_basic_user_file /etc/nginx/.htpasswd;
  }
}
EOF


# Configure nginx server block symlinks
sudo ln -s /etc/nginx/sites-available/munki /etc/nginx/sites-enabled/munki
sudo rm /etc/nginx/sites-enabled/default


# Set up samba
echo
echo 'SMB password for munki user'
sudo smbpasswd -a munki


#cat >> /etc/samba/smb.conf << EOL
sudo bash -c "cat >> /etc/samba/smb.conf" << EOL
[munki_repo]
path = /srv/munki_repo
available = yes
valid users = munki
read only = no
browseable = yes
public = no
writable = yes
EOL


# Restart services
sudo systemctl restart nginx
sudo systemctl restart smbd
