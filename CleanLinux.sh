#!/bin/bash

echo
echo -------------------------------------------------------------------------------------------------------------
echo BEGINNING TO CLEAN…
echo -------------------------------------------------------------------------------------------------------------
echo
sleep 2
sudo apt-get --purge autoremove -y
sudo apt-get autoclean -y
echo -------------------------------------------------------------------------------------------------------------
echo DONE, YOUR SYSTEM IS CLEAN NOW!
echo -------------------------------------------------------------------------------------------------------------
echo
echo
sleep 2
echo -------------------------------------------------------------------------------------------------------------
echo STARTING UPDATE
echo -------------------------------------------------------------------------------------------------------------
sudo apt update -y
sudo apt upgrade -y
echo -------------------------------------------------------------------------------------------------------------
echo EVERYTHING IS UP TO DATE, CONGRATULATIONS
echo -------------------------------------------------------------------------------------------------------------
echo
echo
sleep 5
