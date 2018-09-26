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
