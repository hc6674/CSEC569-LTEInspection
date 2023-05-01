import pyshark
import subprocess
import os

def parse_pcap():
    capture = pyshark.FileCapture('ltesniffer_dl_mode.pcap')
    for packet in capture:
        print(packet)


def find_mnc(path, freq):
    # Run with the parameters
    exec_path = ''.join([path, "LTESniffer"])
    print("Recording LTE Packets...")
    try:
        result = subprocess.run([exec_path , '-A', '2', '-W', '4', '-f', str(freq), '-C', '-m', '0', '-a', "num_recv_frames=512,id=2"], timeout=20, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)    
    except:
        print("Recording Finished...")

    # Clean up unneeded files
    os.remove("mcs_statistic.csv")
    os.remove("ul_sample.raw")
    os.remove("api_collector.pcap")

    mnc, mcc = parse_pcap()
    print(f"MNC : {mnc} MCC : {mcc}")
    return(mnc, mcc)


find_mnc("/home/brayden/Clones/LTESniffer/build/src/", 739e6)