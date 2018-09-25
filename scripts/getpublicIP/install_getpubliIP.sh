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