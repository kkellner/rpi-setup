#!/bin/bash -xv
#
# Configure a new Raspberry PI
# which has Raspbian Buster Lite
#
# To run this config script, install git, clone repo and run script.
# Commands:
#
# ssh-keygen -R raspberrypi.local
# ssh -o "StrictHostKeyChecking no" pi@raspberrypi.local
# Default Password: raspberry
# sudo apt-get install -y git
# git clone https://github.com/kkellner/rpi-setup.git
# cd rpi-setup; ./config.sh NEW_HOSTNAME

configFile=/boot/config.txt

hostname=$1

if [ -z "${hostname}" ]; then
   echo "Hostname arg required"
   exit 1
fi

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y python3-pip

# Configuring I2C
sudo apt-get install -y python-smbus
sudo apt-get install -y i2c-tools

# TODO: configure i2c via command-line
# sudo raspi-config 

sudo apt-get install -y python3-rpi.gpio

sudo pip3 install RPI.GPIO
sudo pip3 install adafruit-blinka
sudo pip3 install adafruit-circuitpython-neopixel
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

#####################################################
# Turn on peripherals

sudo raspi-config nonint do_i2c 0
#sudo raspi-config nonint do_spi 0
#sudo raspi-config nonint do_onewire 0
#sudo raspi-config nonint do_memory_split %d


rclocalFile=/etc/rc.local

#####################################################
# Turn off HDMI
grep -Eq "^/usr/bin/tvservice -o" ${rclocalFile}
if [[ $? != 0 ]]; then
    # Remove the "exit 0" last line of file
    sudo sed -i '$ d' ${rclocalFile}
    echo "# Disable HDMI" | sudo tee -a ${rclocalFile} > /dev/null 
    echo "/usr/bin/tvservice -o" | sudo tee -a ${rclocalFile} > /dev/null
    echo "exit 0" | sudo tee -a ${rclocalFile} > /dev/null 
fi


#####################################################
# Turn off USB / Ethernet port
grep -Eq "/sys/devices/platform/soc/3f980000.usb/buspower" ${rclocalFile}
if [[ $? != 0 ]]; then
    # Remove the "exit 0" last line of file
    sudo sed -i '$ d' ${rclocalFile}
    echo "# Disable all USB (which include hard-wire ethernet port)" | sudo tee -a ${rclocalFile} > /dev/null 
    echo "echo 0 > /sys/devices/platform/soc/3f980000.usb/buspower" | sudo tee -a ${rclocalFile} > /dev/null
    echo "exit 0" | sudo tee -a ${rclocalFile} > /dev/null 
fi


#####################################################
# Configure max memory to CPU
grep -Eq "^gpu_mem=" ${configFile}
if [[ $? != 0 ]]; then
    echo "# Min memory to GPU to give to CPU" | sudo tee -a ${configFile} > /dev/null 
    echo "gpu_mem=16" | sudo tee -a ${configFile} > /dev/null 
fi


#####################################################
# Disable IPV6
ipv6File=/etc/modprobe.d/ipv6.conf
if [ ! -f ${ipv6File} ]; then
sudo cat <<EOT | sudo tee -a ${ipv6File} > /dev/null
# added to disable ipv6
options ipv6 disable_ipv6=1
# added to prevent ipv6 driver from loading
blacklist ipv6
EOT
fi

#####################################################
# Reboot if kernel panic:
grep -Eq "^kernel.panic" /etc/sysctl.conf
if [[ $? != 0 ]]; then
    echo "kernel.panic = 10" | sudo tee -a /etc/sysctl.conf > /dev/null 
fi


#####################################################
# Setup read-only filesystem
sudo swapoff --all
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo systemctl disable dphys-swapfile.service
sudo update-rc.d dphys-swapfile remove

fstabFile=/etc/fstab

sudo sed -i -e 's/vfat    defaults /vfat    defaults,noatime,ro /g' ${fstabFile}
sudo sed -i -e 's/ext4    defaults,noatime /ext4    defaults,noatime,ro /g' ${fstabFile}

grep -Eq "tmpfs" ${fstabFile}
if [[ $? != 0 ]]; then
sudo cat <<EOT | sudo tee -a ${fstabFile} > /dev/null
tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=0755,size=10M 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=0755,size=1M 0 0
tmpfs /var/log tmpfs defaults,noatime,nosuid,nodev,noexec,mode=0755 0 0
EOT
fi

#####################################################
# Setup read-only filesystem aliases
bashrcFile=/etc/bash.bashrc
grep -Eq "alias ro" ${bashrcFile}
if [[ $? != 0 ]]; then
sudo cat <<'EOT' | sudo tee -a /etc/bash.bashrc > /dev/null
# set variable identifying the filesystem you work in (used in the prompt below)
set_bash_prompt(){
    fs_mode=$(mount | sed -n -e "s/^\/dev\/.* on \/ .*(\(r[w|o]\).*/\1/p")
    PS1='\[\033[01;32m\]\u@\h${fs_mode:+($fs_mode)}\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
}
 
alias ro='sudo mount -o remount,ro / ; sudo mount -o remount,ro /boot'
alias rw='sudo mount -o remount,rw / ; sudo mount -o remount,rw /boot'
 
# setup fancy prompt"
PROMPT_COMMAND=set_bash_prompt
EOT
fi


#####################################################
# Disable auto-updates - technically it doesn't do anything since we have a 
# read-only file system, but why try?
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable apt-daily-upgrade.service
