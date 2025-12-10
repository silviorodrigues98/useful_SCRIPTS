#! /bin/bash

sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER

#REPLACE IT WITH YOUR USERNAME
sudo usermod -a -G dialout <username>

echo OK
