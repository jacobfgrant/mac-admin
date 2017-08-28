#!/bin/sh

#  set-outlook.sh
#  
#
#  Created by Jacob F. Grant
#
#  Created: 04/20/17
#
#  Requires duti
#

# Set path of DUTI
DUTI=/usr/local/bin/duti

$DUTI -s com.microsoft.outlook mailto
