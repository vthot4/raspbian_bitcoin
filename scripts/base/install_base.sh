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

function update_firmware ()
{
    ## Update firmware of rasberry PI
    log "(..update_firmware..) Updating the raspberry PI firmware"
    sudo rpi-update
}


function update_raspbian ()
{
    ## Update and upgrade raspbian
    log "(..update_raspbian..) Update and Upgrade Raspbian"
    sudo apt-get update 
    sudo apt-get upgrade -f -y --force-yes
    sudo apt-get -y dist-upgrade

    #if [ -f /var/run/reboot-required ]; then
    #   log "(..update_raspbian..) Reboot required!"
    #fi

    ## Remove and clean some packages not needed.
    log "(..update_sapbian..) Remove and clean packages not needed"
    sudo apt-get remove -y --purge libreoffice* wolfram-engine sonic-pi scratch minecraft-pi python3-thonny geany*
    sudo apt-get clean
    sudo apt-get -y autoremove

}

function install_requirements ()
{
    ## Install requirements
    log "(..install_requirements..) Installing requirements."
    sudo apt-get install -y git curl dphys-swapfile net-tools
    sudo apt-get install -y autoconf automake build-essential git libtool libevent-dev libgmp-dev libsqlite3-dev python python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libssl-dev libzmq3-dev  

}


function install_lcd ()
{
    ## Configure drivers for LCD
    ## --> From RASPIBLITZ
    sudo apt-mark hold raspberrypi-bootloader
    git clone https://github.com/goodtft/LCD-show.git
    sudo chmod -R 755 LCD-show
    sudo chown -R $USER:$USER LCD-show
    ## Make LCD screen rotation correct
    sudo sed --in-place -i "57s/.*/dtoverlay=tft35a:rotate=270/" /boot/config.txt
    cd LCD-show/
    sudo ./LCD35-show
}

function conf_limits ()
{
    ## Change limits. Increase open files limit
    ## based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_20_pi.md#increase-your-open-files-limit
    ##
    log "(..conf_limits..) Change limits...Increase open file limits." 
    sudo sed --in-place -i "56s/.*/*    soft nofile 128000/" /etc/security/limits.conf
    sudo bash -c "echo '*    hard nofile 128000' >> /etc/security/limits.conf"
    sudo bash -c "echo 'root soft nofile 128000' >> /etc/security/limits.conf"
    sudo bash -c "echo 'root hard nofile 128000' >> /etc/security/limits.conf"

    sudo bash -c "echo 'session required pam_limits.so' >>/etc/pam.d/common-session"
    sudo bash -c "echo 'session required pam_limits.so' >>/etc/pam.d/common-session-noninteractive"
    sudo sed --in-place -i "25s/.*/session required pam_limits.so/" /etc/pam.d/common-session-noninteractive

}

function ssh_conf ()
{
    ## Start ssh service and enable with systemctl
    case "$1" in
        start)
            log "(..ssh_conf..) Enable ssh service."
            sudo systemctl enable ssh
            sudo systemctl start ssh
            ;;
        stop)
            log "(..ssh_conf..) Disable ssh service."
            sudo systemctl disable ssh
            sudo systemctl stop ssh
            ;;
        *)
            echo " usage: ssh_conf {start|stop}"
    esac
    
}

function reboot_now ()
{
    ## Reboot raspberry now
     log "(..reboot_now..) Reboot system..."
     sudo shutdown -r reboot_now
}

update_firmware
update_raspbian
install_requirements
conf_limits
ssh_conf start
install_lcd
