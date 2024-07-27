import neo
import numpy as np

# Load the .ns5 or .ns3 file
# in_file = ('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/574_Screening/Experiment4/Neural Data/'
#            '20240720-173300/20240720-173300-001.ns5')
# out_file = 'test/Screening/574_Screening/data_blackrock.ns5'

in_file = ('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/574_Screening/Experiment4/Neural Data/'
           '20240720-173300/20240720-173300-001.ns3')
out_file = 'test/Screening/574_Screening/data_blackrock.ns3'

reader = neo.io.BlackrockIO(filename=in_file)
block = reader.read_block()

# Iterate through segments and signals to select the first 3 channels
for seg, segment in enumerate(block.segments):
    print(f'seg: {seg}')
    for i, analog_signal in enumerate(segment.analogsignals):
        print(i)
        signal = analog_signal.magnitude  # Get the signal data as a numpy array
        new_signal = signal[:, :3]  # Select the first three channels

        # Create a new AnalogSignal with the selected channels
        new_analog_signal = neo.AnalogSignal(new_signal,
                                             sampling_rate=analog_signal.sampling_rate,
                                             units=analog_signal.units,
                                             channel_index=analog_signal.channel_index[:3])

        # Replace the original signal with the new signal
        segment.analogsignals[i] = new_analog_signal

# Save the modified block to a new file
writer = neo.io.BlackrockIO(filename=out_file)
writer.write_block(block)
