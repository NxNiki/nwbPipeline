import os.path

import numpy as np
import warnings
from mat73 import loadmat
from datetime import timedelta
from typing import List, Union, Optional, Tuple


GAP_THRESHOLD = 2
def combine_csc(
        timestamp_files: List[str],
        signal_files: Optional[List[str]],
        max_gap_duration: Optional[float]=None,
        use_single_precision: bool=True
) -> Tuple[np.ndarray, np.ndarray, float, float]:
    """
    Combine CSC signals, filling gaps with NaNs if the gap between segments is larger than the threshold.
    Set signal_files to empty to only process timestamp_files.

    :param signal_files: list of signal file paths
    :param timestamp_files: list of timestamp file paths
    :param max_gap_duration: maximum gap duration to fill between segments, default is infinity
    :param use_single_precision: boolean to use single precision for output, default is True
    :return: combined signal, combined timestamps, sampling interval duration, start of timestamps
    """

    if max_gap_duration is None:
        max_gap_duration = np.inf

    # Error checking for empty files and mismatch lengths
    if len(timestamp_files) != len(signal_files) and signal_files:
        raise ValueError("combine_CSC: mismatch in length of timestamp_files and signal_files")

    process_signal = True
    if not signal_files:
        process_signal = False
        warnings.warn("combine_csc: no signal files provided")

    num_files = len(timestamp_files)

    signal_combined = [None] * num_files
    timestamps_combined = [None] * num_files
    sampling_intervals = np.full(num_files, np.nan)

    # Read timestamps and signals
    for i in range(num_files):
        timestamps_combined[i], _, sampling_intervals[i] = read_timestamps(timestamp_files[i])
        if process_signal:
            if file_exists(signal_files[i]):
                print(f"Reading CSC (order {i + 1}): {signal_files[i]}")
                signal_combined[i], sampling_interval_csc = read_csc(signal_files[i])
                if np.isnan(sampling_intervals[i]):
                    sampling_intervals[i] = sampling_interval_csc
            else:
                warnings.warn(f"CSC file does not exist: {signal_files[i]}. Data will be filled with NaNs")
                signal_combined[i] = np.full(len(timestamps_combined[i]), np.nan)

    # Check lengths of signals and timestamps
    timestamp_lengths = [len(t) for t in timestamps_combined]
    signal_lengths = [len(s) if s is not None else 0 for s in signal_combined]

    if any(signal_lengths) and any(ts_len != sig_len for ts_len, sig_len in zip(timestamp_lengths, signal_lengths)):
        raise ValueError("Mismatched length of signal and timestamps")

    unique_intervals = np.unique(sampling_intervals[~np.isnan(sampling_intervals)])
    if len(unique_intervals) > 1:
        raise ValueError("Sampling intervals do not match across files!")

    sampling_interval_duration = sampling_intervals[0]

    # Fill gaps between experiments/segments with NaNs
    signal_gap = [None] * num_files
    timestamps_gap = [None] * num_files
    for i in range(1, num_files):
        gap_interval = min((timestamps_combined[i][0] - timestamps_combined[i - 1][-1]), max_gap_duration)
        if gap_interval / sampling_interval_duration > GAP_THRESHOLD:
            gap_length = int(np.floor(gap_interval / sampling_interval_duration))
            signal_gap[i - 1] = np.full(gap_length, np.nan)
            timestamps_gap[i - 1] = np.arange(
                timestamps_combined[i - 1][-1] + sampling_interval_duration,
                timestamps_combined[i - 1][-1] + gap_length * sampling_interval_duration,
                sampling_interval_duration
            )

    # Combine timestamps and signals
    timestamps_combined = [
        np.hstack((timestamps_combined[i], timestamps_gap[i] if timestamps_gap[i] is not None else []))
        for i in range(num_files)]
    combined_timestamps = np.hstack(timestamps_combined)

    if process_signal:
        signal_combined = [np.hstack((signal_combined[i], signal_gap[i] if signal_gap[i] is not None else []))
                           for i in range(num_files)]
        combined_signal = np.hstack(signal_combined)
    else:
        combined_signal = None

    if combined_timestamps.size == 0:
        return combined_signal, [], sampling_interval_duration, []

    # Adjust timestamps for precision
    timestamps_start = combined_timestamps[0]
    combined_timestamps -= timestamps_start

    if use_single_precision:
        combined_timestamps = np.single(combined_timestamps)
        if np.all(np.diff(combined_timestamps) != 0):
            combined_timestamps = np.single(combined_timestamps)
        combined_signal = np.single(combined_signal) if combined_signal is not None else None

    return combined_signal, combined_timestamps, sampling_interval_duration, timestamps_start

def read_timestamps(filename: str) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Read timestamps from a .mat file. Handles different versions where the samplingInterval may or may not exist
    and can be a duration object or a float (in seconds). The function will return the sampling interval as a float
    in seconds and NaN if it does not exist.

    :param filename: path to the .mat file
    :return: timestamps (1D array), duration (in seconds), samplingInterval (in seconds or NaN)
    """

    mat_data = loadmat(filename)

    # Load timestamps
    timestamps = mat_data['timeStamps'].flatten()

    # Calculate duration
    time_end = mat_data['timeendSeconds'].item()
    time_start = mat_data['time0'].item()
    duration = time_end - time_start

    # Check for the existence of samplingInterval and handle different formats
    sampling_interval_seconds = mat_data['samplingIntervalSeconds'].item()

    return timestamps, duration, sampling_interval_seconds

def read_csc(filename: str):
    """
    Read CSC signal from a .mat file and convert the samplingInterval to seconds.

    :param filename: path to the .mat file
    :return: signal (1D array), samplingInterval in seconds
    """

    # Load the .mat file
    mat_data = loadmat(filename)

    # Read the signal
    signal = mat_data['data'].flatten()

    # Check if the file contains signalRemovePLI
    if 'ADBitVolts' in mat_data and not np.isnan(mat_data['ADBitVolts']):
        signal = signal.astype(np.float32) * mat_data['ADBitVolts'].item() * 1e6  # Convert to micro volts
    else:
        warning_message = "ADBitVolts is NaN; your CSC data will not be scaled."
        warnings.warn(warning_message)

    # Handle sampling interval
    if 'samplingIntervalSeconds' in mat_data:
        sampling_interval_seconds = mat_data['samplingIntervalSeconds'].item()
        # Ensure the units of sampling intervals are appropriate
        while 1 / sampling_interval_seconds < 500:
            warnings.warn("Scaling samplingIntervalSeconds down by 1000")
            sampling_interval_seconds /= 1000
    else:
        raise ValueError("samplingIntervalSeconds not found in the file")

    return signal, sampling_interval_seconds

def file_exists(filepath: str) -> bool:
    """
    Check if a signal file exists.
    """
    return os.path.exists(filepath)



if __name__ == '__main__':

    csc_files = [
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_macro/LA9_004.mat',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_macro/LA9_005.mat'
    ]
    timestamp_files = [
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_macro/lfpTimeStamps_004.mat',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_macro/lfpTimeStamps_005.mat'
    ]

    combined_signal, combined_timestamps, sampling_interval_duration, timestamps_start = combine_csc(timestamp_files,
                                                                                                     csc_files)