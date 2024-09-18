import os.path
import warnings
from datetime import timedelta
from typing import List, Optional, Tuple, Union

import numpy as np
import numpy.typing as npt
from mat73 import loadmat

GAP_THRESHOLD = 2


def combine_csc(
    timestamp_files: List[str],
    signal_files: Optional[List[str]] = None,
    max_gap_duration: float = np.inf,
    use_single_precision: bool = True,
) -> Tuple[npt.NDArray[np.float_], Optional[npt.NDArray[np.float_]], float, float]:
    """
    Combine CSC signals, filling gaps with NaNs if the gap between segments is larger than a threshold.
    Set signal_files to empty to only process timestamp_files.

    :param signal_files: list of signal file paths
    :param timestamp_files: list of timestamp file paths
    :param max_gap_duration: maximum gap duration (seconds) to fill between segments. The gap exceeding max_gap_duration
        will be discarded.
    :param use_single_precision: boolean to use single precision for output, default is True
    :return: combined signal, combined timestamps, sampling interval duration, start of timestamps
    """

    # Error checking for empty files and mismatch lengths
    if signal_files is not None and len(timestamp_files) != len(signal_files):
        raise ValueError(
            "combine_csc: mismatch in length of timestamp_files and signal_files"
        )

    timestamps_to_combine, sampling_intervals, signal_to_combine = read_data(
        timestamp_files, signal_files
    )
    check_data_length(timestamps_to_combine, signal_to_combine)
    sampling_interval_seconds = check_sampling_intervals(sampling_intervals)

    combined_timestamps, combined_signal = fill_gaps(
        timestamps_to_combine,
        signal_to_combine,
        max_gap_duration,
        sampling_interval_seconds,
    )

    combined_timestamps, timestamps_start = process_timestamps(
        combined_timestamps, use_single_precision
    )

    if use_single_precision and combined_signal is not None:
        combined_signal = combined_signal.astype(np.float32)

    return (
        combined_timestamps,
        combined_signal,
        sampling_interval_seconds,
        timestamps_start,
    )


def read_data(
    timestamp_files: List[str], signal_files: Optional[List[str]]
) -> Tuple[
    List[npt.NDArray[np.float_]],
    npt.NDArray[np.float_],
    Optional[List[npt.NDArray[np.float_]]],
]:
    num_files = len(timestamp_files)
    if signal_files is None or len(signal_files) == 0:
        warnings.warn("combine_csc: no signal files provided")
        signal_files = [""] * num_files

    signal_to_combine = [np.array([])] * num_files
    timestamps_to_combine = [np.array([])] * num_files
    sampling_intervals = np.full(num_files, np.nan)

    # Read timestamps and signals
    for i in range(num_files):
        timestamps_to_combine[i], _, sampling_intervals[i] = read_timestamps(
            timestamp_files[i]
        )
        if file_exists(signal_files[i]):
            print(f"Reading CSC (order {i + 1}): {signal_files[i]}")
            signal_to_combine[i], sampling_interval_csc = read_csc(signal_files[i])
            if np.isnan(sampling_intervals[i]):
                sampling_intervals[i] = sampling_interval_csc
        else:
            warnings.warn(
                f"CSC file does not exist: {signal_files[i]}. Data will be filled with NaNs"
            )
            signal_to_combine[i] = np.full(len(timestamps_to_combine[i]), np.nan)

    if signal_files is None or len(signal_files) == 0:
        return timestamps_to_combine, sampling_intervals, None

    return timestamps_to_combine, sampling_intervals, signal_to_combine


def check_sampling_intervals(sampling_intervals: npt.NDArray[np.float_]) -> float:
    unique_intervals = np.unique(sampling_intervals[~np.isnan(sampling_intervals)])
    if len(unique_intervals) > 1:
        raise ValueError("Sampling intervals do not match across files!")
    return float(unique_intervals.item())


def process_timestamps(
    timestamps: npt.NDArray[np.float_], use_single_precision: bool
) -> Tuple[npt.NDArray[np.float_], float]:
    """
    convert timestamps form unix time to relative time with start time.
    :param timestamps:
    :param use_single_precision: if true, try to convert timestamps to single precision, start time will not be
        converted.
    :return:
    """
    timestamps_start = timestamps[0].item()
    timestamps -= timestamps_start

    if use_single_precision:
        timestamps_single = timestamps.astype(np.float32)
        if not np.all(np.isclose(np.diff(timestamps), 0)):
            timestamps = timestamps_single

    return timestamps, timestamps_start


def check_data_length(
    timestamps_to_combine: List[npt.NDArray[np.float_]],
    signals_to_combine: Optional[List[npt.NDArray[np.float_]]],
) -> None:
    """
    check if length of timestamps and signal match for each segment.
    :param timestamps_to_combine:
    :param signals_to_combine:
    :return:
    """

    if signals_to_combine is None or len(signals_to_combine) == 0:
        return

    timestamp_lengths = [len(t) if t is not None else 0 for t in timestamps_to_combine]
    signal_lengths = [len(s) if s is not None else 0 for s in signals_to_combine]

    if any(signal_lengths) and any(
        ts_len != sig_len for ts_len, sig_len in zip(timestamp_lengths, signal_lengths)
    ):
        raise ValueError("Mismatched length of signal and timestamps")


def fill_gaps(
    timestamps: List[npt.NDArray[np.float_]],
    signals: Optional[List[npt.NDArray[np.float_]]],
    max_gap_duration: float,
    sampling_interval_seconds: float,
) -> Tuple[npt.NDArray[np.float_], Optional[npt.NDArray[np.float_]]]:
    """
    Fill gaps between experiments/segments with NaNs.
    :param timestamps:
    :param signals:
    :param max_gap_duration:
    :param sampling_interval_seconds:
    :return:
    """

    num_files = len(timestamps)
    signal_gap = [np.array([])] * num_files
    timestamps_gap = [np.array([])] * num_files
    for i in range(1, num_files):
        gap_interval = min(
            (timestamps[i][0].item() - timestamps[i - 1][-1].item()),
            max_gap_duration,
        )
        if gap_interval / sampling_interval_seconds > GAP_THRESHOLD:
            gap_length = int(np.floor(gap_interval / sampling_interval_seconds))
            signal_gap[i - 1] = np.full(gap_length, np.nan)
            timestamps_gap[i - 1] = np.arange(
                timestamps[i - 1][-1] + sampling_interval_seconds,
                timestamps[i - 1][-1] + gap_length * sampling_interval_seconds,
                sampling_interval_seconds,
            )

    # Combine timestamps and signals
    timestamps_to_combine = [
        np.hstack(
            (
                timestamps[i],
                timestamps_gap[i] if timestamps_gap[i] is not None else [],
            )
        )
        for i in range(num_files)
    ]
    combined_timestamps = np.hstack(timestamps_to_combine)

    if signals is not None:
        signal_to_combine = [
            np.hstack((signals[i], signal_gap[i] if signal_gap[i] is not None else []))
            for i in range(num_files)
        ]
        combined_signal = np.hstack(signal_to_combine)
    else:
        combined_signal = None

    return combined_timestamps, combined_signal


def read_timestamps(filename: str) -> Tuple[npt.NDArray[np.float_], float, float]:
    """
    Read timestamps from a .mat file. Handles different versions where the samplingInterval may or may not exist
    and can be a duration object or a float (in seconds). The function will return the sampling interval as a float
    in seconds and NaN if it does not exist.

    :param filename: path to the .mat file
    :return: timestamps (1D array), duration (in seconds), samplingInterval (in seconds or NaN)
    """

    mat_data = loadmat(filename)

    # Load timestamps
    timestamps = mat_data["timeStamps"].flatten()

    # Calculate duration
    time_end = mat_data["timeendSeconds"].item()
    time_start = mat_data["time0"].item()
    duration = time_end - time_start

    # Check for the existence of samplingInterval and handle different formats
    sampling_interval_seconds = mat_data["samplingIntervalSeconds"].item()

    return timestamps, duration, sampling_interval_seconds


def read_csc(filename: str) -> Tuple[npt.NDArray[np.float_], float]:
    """
    Read CSC signal from a .mat file and convert the samplingInterval to seconds.

    :param filename: path to the .mat file
    :return: signal (1D array), samplingInterval in seconds
    """

    # Load the .mat file
    mat_data = loadmat(filename)

    # Read the signal
    csc_signal = mat_data["data"].flatten()

    # Check if the file contains signalRemovePLI
    if "ADBitVolts" in mat_data and not np.isnan(mat_data["ADBitVolts"]):
        csc_signal = (
            csc_signal.astype(np.float32) * mat_data["ADBitVolts"].item() * 1e6
        )  # Convert to micro volts
    else:
        warning_message = "ADBitVolts is NaN; your CSC data will not be scaled."
        warnings.warn(warning_message)

    # Handle sampling interval
    if "samplingIntervalSeconds" in mat_data:
        sampling_interval_seconds = mat_data["samplingIntervalSeconds"].item()
        # Ensure the units of sampling intervals are appropriate
        while 1 / sampling_interval_seconds < 500:
            warnings.warn("Scaling samplingIntervalSeconds down by 1000")
            sampling_interval_seconds /= 1000
    else:
        raise ValueError("samplingIntervalSeconds not found in the file")

    return csc_signal, sampling_interval_seconds


def file_exists(filepath: str) -> bool:
    """
    Check if a signal file exists.
    """
    return os.path.exists(filepath)


if __name__ == "__main__":
    import matplotlib.pyplot as plt

    csc_files_test = [
        "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/"
        "CSC_macro/LA9_004.mat",
        "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/"
        "CSC_macro/LA9_005.mat",
    ]
    timestamp_files_test = [
        "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/"
        "CSC_macro/lfpTimeStamps_004.mat",
        "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/"
        "CSC_macro/lfpTimeStamps_005.mat",
    ]

    (
        timestamps_test,
        signal_test,
        sampling_interval_duration_test,
        timestamps_start_test,
    ) = combine_csc(timestamp_files_test, csc_files_test)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))
    ax1.plot(timestamps_test)
    ax2.plot(signal_test)
    plt.show()
