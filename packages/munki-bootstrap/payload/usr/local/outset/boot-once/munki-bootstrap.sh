#!/bin/sh

#  munki-bootstrap.sh
#  
#
#  Created by Jacob F. Grant on 12/15/16
#
#  Updated: 2/8/17.
#

if [ -f /Library/Preferences/ManagedInstalls.plist ]
then
    sudo rm -f /usr/local/outset/boot-once/munki_bootstrap.sh
exit 0
fi

sudo defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "http://munki-server/munki_repo/"

sudo touch /Users/Shared/.com.googlecode.munki.checkandinstallatstartup

sudo shutdown -r
