#!/bin/bash

# Define functions
parse_pcap() {
    file="ltesniffer_dl_mode.pcap"
    result=$(tshark -Tfields -r "$file" -Y "lte-rrc.c1 == 1" -e "lte-rrc.MCC_MNC_Digit")

    if [ -n "$result" ]; then
        output=(${result//,/ })
        mcc="${output[0]}${output[1]}${output[2]}"
        mnc="${output[3]}${output[4]}${output[5]}"
        echo "$mnc,$mcc"
    else
        echo "Error finding SIB packets"
        echo "0,0"
    fi
}

find_mnc() {
    path="$1"
    freq="$2"

    exec_path="${path}LTESniffer"
    echo "Recording LTE Packets..."
    "${exec_path}" -A 2 -W 4 -f "${freq}" -C -m 0 -a "num_recv_frames=512,id=2" &> /dev/null
    sleep 60
    pkill -f "${exec_path}"

    rm -f mcs_statistic.csv
    rm -f ul_sample.raw
    rm -f api_collector.pcap

    mnc_mcc=$(parse_pcap)
    echo "MNC,MCC: $mnc_mcc"
}

# Call find_mnc function
# Usage: find_mnc <path> <frequency>
# Example: find_mnc "/home/brayden/Clones/LTESniffer/build/src/" "739e6"
find_mnc "/home/brayden/Clones/LTESniffer/build/src/" "739e6"
