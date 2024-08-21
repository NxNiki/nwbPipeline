import os
from pathlib import Path
from typing import Any, List, Tuple, Union

import numpy as np
import scipy.io as sio
from pynwb import NWBHDF5IO


def save_spikes_to_nwb(nwb_file_path: str, exp_file_path: str) -> None:
    spike_file_path = os.path.join(exp_file_path, "CSC_micro_spikes")

    # Load spikes for all channels:
    (
        spike_timestamps,
        spike_waveform,
        spike_waveform_mean,
        spike_electrodes_idx,
    ) = load_spikes(spike_file_path)

    if not spike_timestamps:
        print(f"Warning: no spikes detected in: {spike_file_path}")
        return

    with NWBHDF5IO(nwb_file_path, "r+") as nwb_io:
        nwb = nwb_io.read()

        nwb.add_unit_column(name="waveform_mean", description="Mean Spike Waveforms")
        for i, spike_timestamp in enumerate(spike_timestamps):
            nwb.add_unit(
                spike_times=spike_timestamp,
                electrodes=spike_electrodes_idx[i],
                waveform_mean=spike_waveform_mean,
            )

        nwb_io.write(nwb)
        print(f"NWB file saved successfully to {nwb_file_path}")


def load_spikes(
    spike_file_path: Union[str, Path]
) -> Tuple[
    List[np.ndarray[np.float64, Any]],
    List[np.ndarray[np.float64, Any]],
    np.ndarray[np.float64, Any],
    List[int],
]:
    """
    Read units in spike files and concatenate timestamps, waveform, and electrode index
    in a one-dimensional list. This is used to save spikes into NWB file.
    """
    spike_files = [
        f
        for f in os.listdir(spike_file_path)
        if f.endswith("_spikes.mat") and not f.startswith("._")
    ]

    units_timestamp = []
    units_waveform = []
    units_waveform_mean = []
    electrode_index = []

    for i, spike_file in enumerate(spike_files):
        print(f"loadSpikes: {spike_file}")

        spike_file_name = os.path.splitext(spike_file)[0]

        spikes, spike_class, spike_timestamps = get_spikes(
            spike_file_name, spike_file_path
        )
        units = np.unique(spike_class)  # type: ignore
        for unit in units:
            unit_spikes = spikes[spike_class == unit]
            units_timestamp.append(spike_timestamps[spike_class == unit])
            units_waveform.append(unit_spikes)
            units_waveform_mean.append(np.mean(unit_spikes, axis=0))
            electrode_index.append(i)

    return (
        units_timestamp,
        units_waveform,
        np.array(units_waveform_mean).T,
        electrode_index,
    )


def get_spikes(
    spike_file_name: str, spike_file_path: str
) -> Tuple[np.ndarray[float, Any], np.ndarray[float, Any], np.ndarray[float, Any]]:
    """
    read spikes and remove noise ones (cluster class 0)
    :param spike_file_name:
    :param spike_file_path:
    :return:
    """

    spikes_file = os.path.join(spike_file_path, spike_file_name)
    times_file = os.path.join(
        spike_file_path, f'times_{spike_file_name.replace("_spikes", "")}.mat'
    )
    spikes_data = sio.loadmat(spikes_file)
    spikes = spikes_data["spikes"]
    if os.path.exists(times_file):
        times_data = sio.loadmat(times_file)
        spike_class = times_data["cluster_class"][:, 0]
        spike_timestamps = times_data["cluster_class"][:, 1]

        # Remove rejected spikes
        rejected_spike_indices = times_data["spikeIdxRejected"].flatten()
        spikes = spikes[~rejected_spike_indices]
        spike_class = spike_class[~rejected_spike_indices]

        # Remove un-clustered spikes
        valid_spikes = spike_class != 0
        spikes = spikes[valid_spikes, :]
        spike_class = spike_class[valid_spikes]
        spike_timestamps = spike_timestamps[valid_spikes]
    else:
        print(f"Warning: times file not exist: {times_file}")
        spike_class = np.ones(spikes.shape[0])
        spike_timestamps = spikes_data["spikeTimestamps"].flatten()

    return spikes, spike_class, spike_timestamps


def flatten(nested_list: List[Any]) -> List[Any]:
    """
    Recursively flatten a nested list into a single list.

    Parameters:
    nested_list (list): The list to flatten.

    Returns:
    list: A flattened version of the input list.

    Example:
    --------
    nested_list = [[1, 2], [2, 3], 'a', ['b'], [[4], 5]]
    res = flatten(nested_list)
    print(res)  # Output: [1, 2, 2, 3, 'a', 'b', 4, 5]

    nested_list = [[1, 2], [2, 3], 'a', [], [[4], 5]]
    res = flatten(nested_list)
    print(res)  # Output: [1, 2, 2, 3, 'a', 4, 5]

    nested_list = [[], [2, 3], '', [], [[4], 5]]
    res = flatten(nested_list)
    print(res)  # Output: [2, 3, '', 4, 5]
    """

    if not isinstance(nested_list, list):
        return [nested_list]

    flattened_list = []
    for item in nested_list:
        flattened_list.extend(flatten(item))

    return flattened_list
