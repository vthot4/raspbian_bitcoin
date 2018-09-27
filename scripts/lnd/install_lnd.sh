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

LND_VERSION=v0.5-beta
LND_VERSION_CHECK=0.5.0-beta
LND_USER=dladm
LND_URL="https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}"

## Execution trace variables
declare -a LOG="install_$0_$(date +"%F").log"
TRAZA=1     # Enable trace by screen 
TRAZA_LOG=1 # Enable trace by log.
INITIAL_PWD=`pwd`
PGP_KEY="BD599672C804AF2770869A048B80CD2BB8BD8132"

function log ()
{
    ## write log.
    echo -e "$NC"
    test $TRAZA -ne 1 || echo -e $@
    test $TRAZA_LOG -ne 1 || echo -e "$NC [$(date +"%D %T")] $@" >> $LOG
}

function check_exist ()
{
    if [ ! -f "./$1" ]
    then
        log "(..install_bitcoin..) Download $1 not success"
        exit 1
    fi
    log "(..install_bitcoin..) Download $1 success OK"
}


function install_lnd ()
{   
    og "(..install_bitcoin..) Install LND version ${LND_VERSION}"

    cd /home/${LND_USER}/source

    ## Download resources for installation

    sudo -u ${LND_USER} wget ${LND_URL}/lnd-linux-armv7-${LND_VERSION}.tar.gz
    check_exist lnd-linux-armv7-${LND_VERSION}.tar.gz
    sudo -u ${LND_USER} wget ${LND_URL}/manifest-${LND_VERSION}.txt
    check_exist manifest-${LND_VERSION}.txt

    checksum=$(sha256sum --check manifest-${LND_VERSION}.txt --ignore-missing 2>/dev/null | grep '.tar.gz: OK' -c)
    if [ ${checksum} -lt 1 ]; then
         log "(..install_lnd..) CHECKSUM FAILED ..... LND download checksum not OK"
         exit 1
    fi

    sudo -u ${LND_USER} wget ${LND_URL}/manifest-${LND_VERSION}.txt.sig   
    check_exist manifest-${LND_VERSION}.txt.sig
    sudo -u ${LND_USER}  wget https://keybase.io/roasbeef/pgp_keys.asc

    # check gpg finger print
    fingerprint=$(gpg ./pgp_keys.asc 2>/dev/null | grep "${PGP_KEY}" -c)
    if [ ${fingerprint} -lt 1 ]; then
        log "(..install_lnd..) FINGER PRINT ..... LND download PGP author not OK"
        exit 1
    fi

    gpg --import ./pgp_keys.asc
    verifyResult=$(gpg --verify manifest-${LND_VERSION}.txt.sig 2>&1)
    goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
    echo "goodSignature(${goodSignature})"
    correctKey=$(echo ${verifyResult} |  grep "using RSA key ${PGP_KEY_R: -28}" -c)
    echo "correctKey(${correctKey})"
    if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
        log "(..install_lnd..) PGP verification ..... PGP not OK"
        ## ToDo .....
        ##exit 1
    fi

    # Install lnd software

    sudo -u ${LND_USER} tar -xvf lnd-linux-armv7-${LND_VERSION}.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-armv7-${LND_VERSION}/*
    sleep 5
    installed=$(sudo -u ${LND_USER} lnd --version | grep "${LND_VERSION_CHECK}" -c)
    if [ ${installed} -lt 1 ]; then
        log "(..install_lnd..) INSTALL ..... LND install FAILED"
        exit 1
    fi
     log "(..install_lnd..) INSTALL ..... LND install completed OK"

}

function conf_lnd ()
{
    cd ${INITIAL_PWD}
    log "(..install_lnd..) CONFIGURE ..... Configuring lnd"
    sudo -u ${LND_USER} mkdir /home/${LND_USER}/.lnd
    sudo cp ./lnd.conf /home/${LND_USER}/.lnd
    sudo chown ${LND_USER}:${LND_USER} /home/${LND_USER}/.lnd/lnd.conf
    
    # Bitcoin service configure (start and enable with systemd)
    sed "s/USER/${LND_USER}/g" ./lnd.service.template >> lnd.service
    sudo cp  lnd.service /etc/systemd/system/
    sudo systemctl enable lnd.service

}

install_lnd
conf_lnd
