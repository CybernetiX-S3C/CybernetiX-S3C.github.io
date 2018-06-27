#!/bin/bash
clear

if [[ $EUID -ne 0 ]]; then
  echo "You must be root" 2>&1
  exit 1
fi

ARCH=$(uname -m)

if [ "$ARCH" == 'x86_64' ] ; then
  echo "[+] Detected AMD64"
    architecture=amd64
elif [ "$ARCH" == 'i386' ] ; then
  echo "[+] Detected i386"
    architecture=i386
elif [ "$ARCH" == 'i686' ] ; then
  echo "[+] Detected i386"
    architecture=i386
elif [  "$ARCH" == 'armv6l' ] ; then
  echo "[+] Detected ARMEL"
    architecture=armel
elif [  "$ARCH" == 'armv7l' ] ; then
  echo "[+] Detected ARMHF"
    architecture=armhf
else
  echo "Unknown architecture"
    exit 1
fi
sleep 5
echo ""
echo "[+] Changing to /tmp"
cd /tmp

# libv8 package
echo "[+] Downloading libv8 package..."
wget http://ftp.us.debian.org/debian/pool/main/libv/libv8-3.14/libv8-3.14.5_3.14.5.8-8~bpo70+1_${architecture}.deb

sleep 3

# nodejs package
echo "[+] Downloading nodejs package..."
wget http://ftp.tku.edu.tw/Linux/Kali/kali/pool/main/n/nodejs/nodejs_0.10.29~dfsg-1~bpo70+1_${architecture}.deb

sleep 3

# install nodejs / dependency
echo "[+] Installing NodeJS"
dpkg -i libv8*
dpkg -i nodejs_0.10.29~dfsg-1~bpo70+1_${architecture}.deb
ln /usr/bin/nodejs /usr/bin/node

echo "[+] Testing NodeJS version"
node -v

sleep 3

# install npm (you will get error but it works okay)
echo "[+] Installing NPM"
curl https://www.npmjs.org/install.sh | sudo sh

# clean up
echo "[+] Removing temporary files"
rm -rf /tmp/*
