#!/bin/sh

#  munki-bootstrap.sh
#  
#
#  Created by Jacob F. Grant
#
#  Created: 12/15/16
#  Updated: 08/28/17
#

# Set Munki repo URL
MUNKI_REPO_URL='http://munki-server/munki_repo/'


if [ -f /Library/Preferences/ManagedInstalls.plist ]
then
    rm -f /usr/local/outset/boot-once/munki_bootstrap.sh
    exit 0
fi

defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL $MUNKI_REPO_URL

touch /Users/Shared/.com.googlecode.munki.checkandinstallatstartup

shutdown -r
