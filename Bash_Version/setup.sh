#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install required packages
sudo apt install -y git sed wget curl

# Install srsRAN (assuming it's a Debian/Ubuntu-based system)
sudo apt install -y build-essential cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev

# Clone srsRAN repository
git clone https://github.com/srsran/srsRAN.git
cd srsRAN
mkdir build
cd build

# Build srsRAN
cmake ../
make
sudo make install
sudo ldconfig

# Configure srsRAN
sudo srsran_install_configs.sh user
cd ../..

# Make sure your scripts (mnc_sniff.sh, signal_strength.sh, etc.) are executable
chmod +x mnc_sniff.sh
chmod +x signal_strength.sh