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

function install_bitcoin ()
{   
    # Set version of bitcoin
    B_VERSION="0.17.0"
    laanwjPGP="01EA5486DE18A882D4C2684590C8019E36C2E964"
    B_USER=dladm
    B_HOME=/home/${B_USER}/
    B_URL="https://bitcoin.org/bin/bitcoin-core-${B_VERSION}/test.rc4"

    log "(..install_bitcoin..) Install bitcoin version ${B_VERSION}."
    
    # prepare directories
    sudo -u ${B_USER} mkdir -p ${HOME}/source
    cd /home/${B_USER}/source

    # download resources
    sudo -u ${B_USER} wget ${B_URL}/bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz
    if [ ! -f "./bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz" ]
    then
        log "(..install_bitcoin..) !!! FAIL !!! Download BITCOIN BINARY not success."
        exit 1
    fi
    sudo -u ${B_USER} wget ${B_URL}/SHA256SUMS.asc
    if [ ! -f "./SHA256SUMS.asc" ]
    then
        log "(..install_bitcoin..) !!! FAIL !!! Download SHA256SUMS.asc not success."
        exit 1
    fi
    sudo -u ${B_USER} wget https://bitcoin.org/laanwj-releases.asc
    if [ ! -f "./laanwj-releases.asc" ]
    then
        log "(..install_bitcoin..) !!! FAIL !!! Download laanwj-releases.asc not success."
        exit 1
    fi

    # test checksum
    checksum=$(sha256sum --check SHA256SUMS.asc --ignore-missing 2>/dev/null | grep '.tar.gz: La suma coincide' -c)
    if [ ${checksum} -lt 1 ]; then
        echo ""
        log "(..install_bitcoin..) !!! BUILD FAILED --> Bitcoin download checksum not OK"
        exit 1
    fi

    # check gpg finger print
    fingerprint=$(gpg laanwj-releases.asc 2>/dev/null | grep "${laanwjPGP}" -c)
    if [ ${fingerprint} -lt 1 ]; then
        echo ""
        log "(..install_bitcoin..) !!! BUILD FAILED --> Bitcoin download PGP author not OK"
        exit 1
    fi

    gpg --import ./laanwj-releases.asc
    verifyResult=$(gpg --verify SHA256SUMS.asc 2>&1)
    goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
    echo "goodSignature(${goodSignature})"
    correctKey=$(echo ${verifyResult} |  grep "using RSA key ${laanwjPGP: -16}" -c)
    echo "correctKey(${correctKey})"
    
    if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
        echo ""
        log "(..install_bitcoin..) !!! BUILD FAILED --> LND PGP Verify not OK / signatute(${goodSignature}) verify(${correctKey})"
        exit 1
    fi

    # install
    sudo -u ${B_USER} tar -xvf ./bitcoin-${B_VERSION}rc4-arm-linux-gnueabihf.tar.gz
    sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-${B_VERSION}/bin/*
    sleep 3
    installed=$(sudo -u ${B_USER} bitcoind --version | grep "${B_VERSION}" -c)
    if [ ${installed} -lt 1 ]; then
        echo ""
        log "(..install_bitcoin..) !!! BUILD FAILED --> Was not able to install bitcoind version(${B_VERSION})"
        exit 1
    fi

}


