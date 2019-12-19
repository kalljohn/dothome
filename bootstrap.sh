#!/bin/sh

USER=`id -u -n`
SUDO=

if [ $USER != "root" ]; then
    SUDO=sudo
fi

$SUDO sed -i 's%archive.ubuntu.com%free.nchc.org.tw%' /etc/apt/sources.list
$SUDO apt update
$SUDO apt install -y --no-install-recommends --no-upgrade sudo wget curl ca-certificates git make

git config --global http.sslVerify false

git submodule update --init --recursive
