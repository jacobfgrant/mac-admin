#!/bin/sh

#  dock-setup.sh
#  
#
#  Created by Jacob F. Grant on 2/9/17.
#
#
#  Requires docutil (https://github.com/kcrawford/dockutil)
#

# Set path of DOCKUTIL
DOCKUTIL=/usr/local/bin/dockutil


# Delete everything from the dock and replace it with custom dock
$DOCKUTIL --remove all --no-restart

sleep 2 # Delay gives the dock time to inialize the removal

$DOCKUTIL --add '/Applications/Launchpad.app' --no-restart

$DOCKUTIL --add '/Applications/Google Chrome.app' --no-restart

$DOCKUTIL --add '/Applications/Microsoft Outlook.app' --no-restart

$DOCKUTIL --add '/Applications/Microsoft Excel.app' --no-restart

$DOCKUTIL --add '/Applications/Microsoft Word.app' --no-restart

$DOCKUTIL --add '/Applications/Calendar.app' --no-restart

$DOCKUTIL --add '/Applications/Contacts.app' --no-restart

$DOCKUTIL --add '/Applications/LastPass.app' --no-restart

$DOCKUTIL --add '/Applications/Utilities/Managed Software Update.app' --no-restart

#$DOCKUTIL --add '/Applications/App Store.app' --no-restart

$DOCKUTIL --add '/Applications/System Preferences.app' --no-restart

$DOCKUTIL --add '~/' --view grid --display folder --sort name --no-restart

$DOCKUTIL --add '~/Downloads' --view fan --display stack --sort dateadded --no-restart

killall Dock
