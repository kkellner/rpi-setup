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
# sudo apt-get install -y git
# git clone https://github.com/kkellner/rpi-setup.git
# cd rpi-setup
# ./config.sh

hostname=$1

if [ -z "${hostname}" ]; then
   echo "Hostname arg required"
   exit 1
fi

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install python3-pip

# Configuring I2C
sudo apt-get install -y python-smbus
sudo apt-get install -y i2c-tools

# TODO: configure i2c via command-line
# sudo raspi-config 

sudo apt-get install python3-rpi.gpio

sudo pip3 install -y RPI.GPIO
sudo pip3 install -y adafruit-blinka
sudo pip3 install -y adafruit-circuitpython-neopixel
sudo pip3 install pyyaml
sudo pip3 install schedule
sudo pip3 install melopero-vl53l1x
sudo pip3 install psutil


# Add w1thermsensor command.
# Command examples:
#    w1thermsensor ls
#    w1thermsensor all
# From https://github.com/timofurrer/w1thermsensor
sudo apt-get install -y python3-w1thermsensor

# Get the status of all I/O pins from command-line
# Example:  sudo raspi-gpio get
sudo apt-get install -y raspi-gpio



# Wireless / wifi monitor testing
sudo apt-get install -y wavemon


sudo apt-get clean


sudo raspi-config nonint do_hostname "${hostname}"

#sudo raspi-config nonint do_i2c %d
#sudo raspi-config nonint do_spi %d
#sudo raspi-config nonint do_onewire %d
#sudo raspi-config nonint do_memory_split %d
