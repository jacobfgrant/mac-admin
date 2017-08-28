#!/bin/sh

#  finder-sidebar.sh
#  
#
#  Created by Jacob F. Grant
#
#  Created: 02/13/17
#
#  Requires mysides: https://github.com/mosen/mysides
#

# Set path of MYSIDES
MYSIDES=/usr/local/bin/mysides


# Remove unwanted items from sidebar
$MYSIDES remove "All My Files" && sleep 2
$MYSIDES remove "iCloud" && sleep 2
$MYSIDES remove domain-AirDrop && sleep 2


# Add items to sidebar
$MYSIDES add $USER file:///Users/$USER
$MYSIDES add Applications file:///Applications
$MYSIDES add Desktop file:///Users/$USER/Desktop
$MYSIDES add Documents file:///Users/$USER/Documents
$MYSIDES add Downloads file:///Users/$USER/Downloads
#$MYSIDES add Movies file:///Users/$USER/Movies
#$MYSIDES add Music file:///Users/$USER/Music
#$MYSIDES add Pictures file:///Users/$USER/Pictures
