import numpy as np
import uhd 

def calculate_rssi(samples):
    power = np.mean(np.abs(samples) ** 2)
    rssi_db = 10 * np.log10(power)
    return rssi_db


def signal_strength(center_freq):

    usrp = uhd.usrp.MultiUSRP()

    num_samps = 10000000 # number of samples received
    sample_rate = 20e6 # Hz
    gain = 50 # dB

    usrp.set_rx_rate(sample_rate, 0)
    usrp.set_rx_freq(uhd.libpyuhd.types.tune_request(center_freq), 0)
    usrp.set_rx_gain(gain, 0)

    # Set up the stream and receive buffer
    st_args = uhd.usrp.StreamArgs("fc32", "sc16")
    st_args.channels = [0]
    metadata = uhd.types.RXMetadata()
    streamer = usrp.get_rx_stream(st_args)
    recv_buffer = np.zeros((1, 1000), dtype=np.complex64)

    # Start Stream
    stream_cmd = uhd.types.StreamCMD(uhd.types.StreamMode.start_cont)
    stream_cmd.stream_now = True
    streamer.issue_stream_cmd(stream_cmd)

    # Receive Samples
    samples = np.zeros(num_samps, dtype=np.complex64)
    for i in range(num_samps//1000):
        streamer.recv(recv_buffer, metadata)
        samples[i*1000:(i+1)*1000] = recv_buffer[0]

    # Stop Stream
    stream_cmd = uhd.types.StreamCMD(uhd.types.StreamMode.stop_cont)
    streamer.issue_stream_cmd(stream_cmd)

    rssi = calculate_rssi(samples)

    return(rssi)
