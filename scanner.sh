#!/bin/bash

# TODO - SPECIFY BAND TOWER FOUND IN
DEVICE_ARGS="id=2"
BANDS=(12)

# Modify the srsenb.conf file with the newly selected params
modify_conf() {
    :
}

# Take the stdout from the cell_search binary and return list of towers detected
parse_output() {
    towers=()
    while read -r line; do
        if [[ $line == *"Found CELL"* && $line == *"EARFCN"* ]]; then
            towers+=("$line")
        fi
    done <<< "$1"
    printf '%s\n' "${towers[@]}"
}

# Detect what the parameters for the selected tower are
detect_cell_params() {
    :
}

select_tower() {
    printf "\nChoose Cell Tower to Target\n\n"
    i=0
    while [ $i -lt ${#towers[@]} ]; do
        tower_specs=(${towers[$i]// / })
        printf "    $((i+1))) ${tower_specs[2]} ${tower_specs[3]}, ${tower_specs[4]}, ${tower_specs[5]}\n"
        ((i++))
    done

    read -rp $'\nTower Number : ' selection_index
    index=$((selection_index - 1))
    printf '%s\n' "${towers[$index]}"
}

# Run the cell_search binary with args and then return the output
run_scanner() {
    all_output=""
    for band in "${BANDS[@]}"; do
        # Run subprocess to scan for cell towers
        printf "======= Scanning %s Band =======\n" "$band"
        start_time=$(date +%s.%N)
        result=$(./cell_search -a "id=2" -b "$band" 2>/dev/null)
        byte_output=$(printf '%s' "$result")
        output=$(echo "$byte_output" | tr -d '\0')
        all_output+="$output"

        # Print and Return
        time_run=$(echo "$(date +%s.%N) - $start_time" | bc)
        printf "======= Band %s Finished (Took %.2f seconds)=======\n" "$band" "$time_run"
    done
    printf '%s\n' "$all_output"
}

main() {
    output=$(run_scanner)
    towers=$(parse_output "$output")
    selected_tower=$(select_tower "$towers")
    printf '%s\n' "$selected_tower"
    # Write changes to srsenb
}

main
