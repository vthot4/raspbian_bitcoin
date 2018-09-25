#!/bin/bash
##################################################################3
# 
#   Source : RaspiBolt LND Mainnet: script to get public ip address
#   Usage:  /usr/local/bin/getpublicip.sh
#   Description: Writing publicIP adress every X minutes into /run/publicip
#            
#   Configuration:
#       ## Make it executable
#       $ sudo chmod +x /usr/local/bin/getpublicip.sh
#       ## Create systemd unit.
# -------------------------------------------------------- 
#   [Unit]
#   Description=getpublicip.sh: get public ip address from ipinfo.io
#   After=network.target
#
#   [Service]
#   User=root
#   Group=root
#   Type=simple
#   ExecStart=/usr/local/bin/getpublicip.sh
#   ExecStartPost=/bin/sleep 5
#   Restart=always
#   RestartSec=600
#   TimeoutSec=10
#
#   [Install]
#   WantedBy=multi-user.target
# ------------------------------------------------------------
#   enable systemd startup
#   $ sudo systemctl enable getpublicip
#   $ sudo systemctl start getpublicip
#   $ sudo systemctl status getpublicip
#
#   check if data file has been created
#   $ cat /run/publicip


TIME_WAIT=600

while [ 0 ];
    do
    printf "PUBLICIP=$(curl -vv ipinfo.io/ip 2> /run/publicip.log)\n" > /run/publicip;
    sleep ${TIME_WAIT}
done;
