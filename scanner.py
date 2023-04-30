import subprocess
import time

# TODO - SPECIFY BAND TOWER FOUND IN

DEVICE_ARGS = "id=2"
# BANDS=[12]
BANDS=[2,4,12,13,17,66,71]

# Modift the srsenb.conf file with the newly selected params
def modify_conf():
    pass


# Take the stdout from the cell_search binary and return list of towers detected
def parse_output(output):
    towers = []
    output = output.split("\n")
    # Find any towers
    for line in output:
        if "Found CELL" in line and "EARFCN" in line:
            # pull ID and check if greater than 2
            line_id = line.split(" ")
            id = line_id[5][6:]
            id = int(id.strip(","))
            if id > 2:
                towers.append(line)

    return(towers)


# Detect if there are any UEs associated with chosen tower
# Returns True/False
def detect_ue(tower):
    return(False)


def select_tower(towers):
    print("\nChoose Cell Tower to Target\n")
    for i in range(0, len(towers)):
        tower_specs = towers[i].split(" ")
        print(f"    {i+1}) {tower_specs[2]} {tower_specs[3]} {tower_specs[4]} {tower_specs[5]} {tower_specs[11]}")

    selection_index = input("\nTower Number : ")
    index = int(selection_index) - 1
    return(towers[index])


# Run the cell_search binary with args and then return the output
def run_scanner():
    all_output = ""
    for band in BANDS:
        # Run subprocess to scan for cell towers
        print(f"======= Scanning {band} Band =======")
        start_time = time.time()
        result = subprocess.run(['./cell_search', '-a', 'id=2', '-b', str(band)], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        
        # Add Results to accumulator
        byte_output = result.stdout
        output = byte_output.decode("utf-8")
        all_output += output

        # Print and Return
        time_run = "{:.2f}".format(time.time() - start_time)
        print(f"======= Band {band} Finished (Took {time_run} seconds)=======")
    return all_output



def main():
    output = run_scanner()
    towers = parse_output(output)
    while True:
        selected_tower = select_tower(towers)
        print(selected_tower)
        if detect_ue(selected_tower):
            break
        else:
            print("No UEs detected, select new tower")
    # end

    # Sniff SIB information
    # Apply to enb.conf and run srsenb & srsepc

if __name__ == "__main__":
    main()