#!/bin/bash
###########################################################################################
##      
##      Author:  dlightning team
##      Project: dlightning 
##      Version: v0.2 (genesis)
##
###########################################################################################
# based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_30_bitcoin.md#installation
#
# Sequence:
#   --> Create user
#   --> Install Bitcoin
#   --> Configure bitcoin.conf
#   --> Configure systemd
#

## --- VARIABLES ---##

B_VERSION="0.17.0" # Bitcoin Version
PGP_KEY="01EA5486DE18A882D4C2684590C8019E36C2E964" ## gpg ./laanwj-releases.asc
B_USER=dladm
B_USER_PASS=dladm
B_URL="https://bitcoin.org/bin/bitcoin-core-${B_VERSION}/test.rc4"

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



function create_user ()
{
    ## Create user with sudo
    log "(..create_user..) Create user $1 with sudo."
    sudo adduser --disabled-password --gecos "" $1
    sudo adduser $1 sudo
    echo "$1:$2"|sudo chpasswd
    ###---->>>>> execution error!!!!!!!!!!
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


function install_bitcoin () 
{
    log "(..install_bitcoin..) Install bitcoin version ${B_VERSION}"

    ## Prepare environment
    sudo -u ${B_USER} mkdir /home/${B_USER}/source
    cd /home/${B_USER}/source

    ## Download resources for installation
    sudo -u ${B_USER} wget ${B_URL}/bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz
    check_exist bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz
    sudo -u ${B_USER} wget ${B_URL}/SHA256SUMS.asc
    check_exist SHA256SUMS.asc
    checksum=$(sha256sum --check SHA256SUMS.asc --ignore-missing 2>/dev/null | grep '.tar.gz: OK' -c)
    if [ ${checksum} -lt 1 ]; then
         log "(..install_bitcoin..) CHECKSUM FAILED ..... Bitcoin download checksum not OK"
         exit 1
    fi

    sudo -u ${B_USER} wget https://bitcoin.org/laanwj-releases.asc
    check_exist laanwj-releases.asc
   
    # check gpg finger print
    fingerprint=$(gpg ./laanwj-releases.asc 2>/dev/null | grep "${PGP_KEY}" -c)
    if [ ${fingerprint} -lt 1 ]; then
        log "(..install_bitcoin..) FINGER PRINT ..... Bitcoin download PGP author not OK"
        exit 1
    fi

    gpg --import ./laanwj-releases.asc
    verifyResult=$(gpg --verify SHA256SUMS.asc 2>&1)
    goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
    echo "goodSignature(${goodSignature})"
    correctKey=$(echo ${verifyResult} |  grep "using RSA key ${PGP_KEY: -16}" -c)
    echo "correctKey(${correctKey})"
    if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
        log "(..install_bitcoin..) PGP verification ..... PGP not OK"
        exit 1
    fi

    # Install bitcoin software
    sudo -u ${B_USER} tar -xvf bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-${B_VERSION}/bin/*
    sleep 5
    installed=$(sudo -u ${B_USER} bitcoind --version | grep "${B_VERSION}" -c)
    if [ ${installed} -lt 1 ]; then
        log "(..install_bitcoin..) INSTALL ..... Bitcoin install FAILED"
        exit 1
    fi
     log "(..install_bitcoin..) INSTALL ..... Bitcoin install completed OK"
     cd
}

function conf_bitcoin ()
{
    sudo -u ${B_USER} mkdir /home/${B_USER}/.bitcoin
    sudo cp ./bitcoin.conf /home/${B_USER}/.bitcoin
    sudo chown ${B_USER}:${B_USER} /home/${B_USER}/.bitcoin/bitcoin.conf
    

}

## --- MAIN --- ##

create_user ${B_USER} ${B_USER_PASS}
install_bitcoin