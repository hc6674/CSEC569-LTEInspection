#!/bin/bash

center_freq="$1"
gain=50
samp_rate=20e6

# Set duration for uhd_fft to run
duration=10

# Run uhd_fft, redirect output to a log file
uhd_fft -f "${center_freq}" -s "${samp_rate}" -g "${gain}" -N "${duration}" > uhd_fft_output.log 2>&1

# Extract the average signal strength from the log file
avg_power=$(grep -oP 'Average: \K(-?\d+\.\d+)' uhd_fft_output.log)

# Calculate RSSI in dB
rssi=$(echo "10 * l(${avg_power}) / l(10)" | bc -l)

# Print the result
echo "RSSI: $rssi dB"
