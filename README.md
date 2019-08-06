# rpi-setup
Raspberry pi Setup

Use purpose of this repo is to hold a script used to configure a Raspberry PI with all needed common software/libraries used for most of my projects.


To run this config script, install git on Raspberry PI, clone repo on Raspberry PI and run script.

To do this run the following commands:

```
ssh-keygen -R raspberrypi.local
ssh -o "StrictHostKeyChecking no" pi@raspberrypi.local
# Default Password: raspberry
sudo apt-get install -y git
git clone https://github.com/kkellner/rpi-setup.git
cd rpi-setup; ./config.sh --hostname new-hostname --password pi-user-password
```
