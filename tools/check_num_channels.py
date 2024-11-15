"""
Check if the number of channels and channel names are consistent across experiments.
This is used for patient 563 for which the Neuralynx config file is changed between experiments.
"""

import glob
import os.path
import re
import warnings


def check_channels(path: str, pattern: str, prev_channels: set) -> set:
    channel_names = get_channel_names(path, pattern)
    print(f"{path} has {len(channel_names)} channels")
    prev_channels = check_channel_names(prev_channels, channel_names)
    return prev_channels

def check_segments(path: str, pattern: str, suffix_pattern: str) -> None:
    """
    check if all channels have same number of segments (with suffix "_00[1-n]").
    """
    channel_names = get_channel_names(path, pattern)
    segment_suffix = set([re.search(suffix_pattern, n).group(1) for n in channel_names])

    if len(segment_suffix) == 1:
        print(f"single segment in {path}")
        return

    prev_channel_names_segment = set()
    for suffix in segment_suffix:
        channel_names_segment = set([c.replace(f"{suffix}.mat", "") for c in channel_names if c.endswith(f"{suffix}.mat")])
        prev_channel_names_segment = check_channel_names(prev_channel_names_segment, channel_names_segment)


def get_channel_names(path: str, pattern: str) -> set:
    channel_files = glob.glob(os.path.join(path, pattern))
    channel_files = set([os.path.basename(f) for f in channel_files])
    return channel_files

def check_channel_names(prev_channels: set, curr_channels: set) -> set:
    if prev_channels:
        if curr_channels != prev_channels:
            warnings.warn("inconsistent channel name detected!")
            print(prev_channels - curr_channels)
            print(curr_channels - prev_channels)
        if len(curr_channels) != len(prev_channels):
            warnings.warn("inconsistent number of channels detected!")
    else:
        prev_channels = curr_channels

    return prev_channels


if __name__ == "__main__":
    file_paths = [
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-10/CSC_micro',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-11/CSC_micro',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-12/CSC_micro',
    ]

    channel_names = set()
    for file_path in file_paths:
        channel_names = check_channels(file_path, "G*_001.mat", channel_names)
        check_segments(file_path, "G*.mat", r"_(\d{3})\.mat")


