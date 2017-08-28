#!/bin/bash

#  chrome-first-run.sh
#  
#
#  Created by Jacob F. Grant
#
#  Created: 08/27/17
#

# Check if Google Chrome is installed

if [[ ! -d "/Applications/Google Chrome.app" ]]
then
    exit 0
fi


# Create user Library Chrome directory and First Run file

if [[ ! -d "/Users/$USER/Library/Application Support/Google/Chrome" ]]
then
    mkdir -p "/Users/$USER/Library/Application Support/Google/Chrome"
fi

touch "/Users/$USER/Library/Application Support/Google/Chrome/First Run"
