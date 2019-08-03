#!/bin/bash
#
# Configure a new Raspberry PI
# which has Raspbian Buster Lite
#
# To run this config script, install git, clone repo and run script.
# Commands:
#
# ssh -o "StrictHostKeyChecking no" pi@raspberrypi.local
# Default Password: raspberry
# sudo apt-get install git
# git clone https://github.com/kkellner/rpi-setup.git
# cd rpi-setup
# ./config.sh

sudo apt-get update -y
sudo apt-get upgrade -y


