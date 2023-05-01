#!/bin/bash

# Create a copy of the srsUE config file
sudo cp ~/.config/srsran/ue.conf ~/.config/srsran/custom_ue.conf

# Modify the custom config file
sudo sed -i 's/dl_earfcn = .*/dl_earfcn = <value>/g' ~/.config/srsran/custom_ue.conf
sudo sed -i 's/enable = .*/enable = mac,nas/g' ~/.config/srsran/custom_ue.conf

# Replace <value> with the actual value of dl_earfcn being used by your phone

# Display the location of the capture files
echo "The location of the capture files is: ~/.config/srsran/pcap"
