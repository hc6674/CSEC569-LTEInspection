#!/bin/bash

# Create a fresh copy of the srsUE config file
sudo cp ~/.config/srsran/ue.conf ~/.config/srsran/new_ue.conf

# Modify the new config file
sudo sed -i 's/dl_earfcn = 3350/#dl_earfcn = 3350/g' ~/.config/srsran/new_ue.conf
sudo sed -i '$a dl_freq = 2450000000' ~/.config/srsran/new_ue.conf
sudo sed -i '$a ul_freq = 2480000000' ~/.config/srsran/new_ue.conf
sudo sed -i 's/#time_adv_nsamples = auto/time_adv_nsamples = auto/g' ~/.config/srsran/new_ue.conf
sudo sed -i 's/enable = .*/enable = mac,nas/g' ~/.config/srsran/new_ue.conf
sudo sed -i 's/log_level = warning/log_level = info/g' ~/.config/srsran/new_ue.conf

# Display the location of the capture files
echo "The location of the capture files is: ~/.config/srsran/pcap"
