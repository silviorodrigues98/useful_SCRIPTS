#! /bin/bash

echo
echo
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo INSTALLING UFW
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo
echo
sleep 2

sudo apt install ufw 

echo
echo
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo UFW INSTALLED
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo
echo

ufw status

sleep 2 

echo
echo
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo CONFIGURING UFW
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo
echo

ufw default allow outgoing
ufw default deny incoming
ufw allow ssh
ufw allow http/tcp
ufw allow https/tcp
sleep 2
ufw status

echo
echo
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo UFW CONFIGURE, RUN ufw enable TO START USING IT
echo ----------------------------------------------------------------------------------------------------------------------------------------------------------
echo
echo

