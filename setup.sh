#!/bin/bash

# Install required packages
sudo apt update
sudo apt install -y python3-pip

# Install PyBOMBS
sudo pip3 install pybombs

# Configure PyBOMBS
pybombs auto-config
pybombs recipes add-defaults

# Install UHD
sudo pybombs install uhd

# Download UHD images
sudo /usr/lib/uhd/utils/uhd_images_downloader.py

# Verify device connectivity
uhd_find_devices

# Take a VM snapshot
# TODO: Add command to take a snapshot here

# Install srsRAN from packages
sudo add-apt-repository -y ppa:softwareradiosystems/srsran
sudo apt update
sudo apt install -y srsran
