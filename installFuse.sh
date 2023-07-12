#! /bin/sh

sudo apt install fuse libfuse2 -y
sudo modprobe fuse
sudo groupadd fuse

user="$(whoami)"
sudo usermod -a -G fuse $user
