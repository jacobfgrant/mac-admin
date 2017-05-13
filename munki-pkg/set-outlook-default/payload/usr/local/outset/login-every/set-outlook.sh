#!/bin/sh

#  set-outlook.sh
#  
#
#  Created by Jacob F. Grant on 4/20/17.
#
#
#  Requires duti
#

# Set path of DUTI
DUTI=/usr/local/bin/duti

$DUTI -s com.microsoft.outlook mailto
