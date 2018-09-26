#!/bin/bash
###########################################################################################
##      
##      Author:  dlightning team
##      Project: dlightning 
##      Version: v0.2 (genesis)
##
###########################################################################################
#
#

##--- VARIABLES ---##
HOSTNAME=dlnode
BOOT_WAIT=0


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



function change_hostname ()
{
    ## Change raspberry PI default hostname
    log "(..configuration..) change_hostname ..... hostname = $1"
    sudo raspi-config nonint do_hostname $1 
}


function boot_wait ()
{
     ## set to wait until network is available on boot (0 seems to yes)
    log "(..configuration..) boot_wait ..... set $1"
    sudo raspi-config nonint do_boot_wait $1
}




###### ----- MAIN ----- ######
change_hostname ${HOSTNAME}
boot_wait ${BOOT_WAIT}

