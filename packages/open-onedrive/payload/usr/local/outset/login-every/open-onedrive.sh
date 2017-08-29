#!/bin/sh

#  open-onedrive.sh
#  
#
#  Created by Jacob F. Grant
#
#  Created: 08/04/17
#  Updated: 08/28/17
#

if
    [ -d "/Applications/OneDrive.app" ] &&
    [ -d /Users/$USER/OneDrive* ] ||
    [ -d /Users/$USER/Documents/OneDrive* ]
then
    open "/Applications/OneDrive.app"
fi
