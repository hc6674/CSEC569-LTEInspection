from scapy.all import *
import subprocess
import os

def parse_pcap():
    file = "ltesniffer_dl_mode.pcap"
    # Need to do lte DLT_USER setup in wireshark - See LTESniffer Help
    result = subprocess.run(["tshark", "-Tfields", "-r" , "ltesniffer_dl_mode.pcap", "-Y", "lte-rrc.c1 == 1", "-e", "lte-rrc.MCC_MNC_Digit"], stdout=subprocess.PIPE)
    
    # Read Results
    byte_output = result.stdout
    output = byte_output.decode("utf-8")

    # Grab MNC & MCC
    try:
        output = output.split(",")
        mcc = output[0] + output[1] + output[2]
        mnc = output[3] + output[4] + output[5]       
        # print(f"MNC : {mnc}\nMCC : {mcc}")
        return(mnc, mcc) 
    except:
        print("Error finding SIB packets")
        return(0, 0)

def find_mnc(path, freq):
    # Run with the parameters
    exec_path = ''.join([path, "LTESniffer"])
    print("Recording LTE Packets...")
    try:
        result = subprocess.run([exec_path , '-A', '2', '-W', '4', '-f', str(freq), '-C', '-m', '0', '-a', "num_recv_frames=512,id=2"], timeout=60, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)    
    except:
        print("Recording Finished...")

    # Clean up unneeded files
    os.remove("mcs_statistic.csv")
    os.remove("ul_sample.raw")
    os.remove("api_collector.pcap")

    mnc, mcc = parse_pcap()
    # print(f"MNC : {mnc} MCC : {mcc}")
    return(mnc, mcc)


# find_mnc("/home/brayden/Clones/LTESniffer/build/src/", 739e6)
