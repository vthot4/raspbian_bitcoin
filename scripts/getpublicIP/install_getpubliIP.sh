#!/bin/bash
###########################################################################################
##      
##      Author:  dlightning team
##      Project: dlightning 
##      Version: v0.2 (genesis)
##
###########################################################################################
#
#   Description: Install getpublicIP.sh

##--- VARIABLES ---##

## Execution trace variables
declare -a LOG="install_$0_$(date +"%F").log"
TRAZA=1     # Enable trace by screen 
TRAZA_LOG=1 # Enable trace by log.

function log ()
{
    ## write log.
    echo -e "$NC"
    test $TRAZA -ne 1 || echo -e $@
    test $TRAZA_LOG -ne 1 || echo -e "$NC [$(date +"%D %T")] $@" >> $LOG
}

## Distribute script and configuration files.
sudo cp ./getpublicIP.sh /usr/local/bin/getpublicIP.sh
sudo chmod +x /usr/local/bin/getpublicIP.sh
sudo cp ./getpublicIP.service /etc/systemd/system/getpublicIP.service

## Enable and star service
sudo systemctl enable getpublicIP
sudo systemctl start getpublicIP
sudo systemctl status getpublicIP

echo " "
echo "check IP ....."
sleep 2
cat /run/publicip