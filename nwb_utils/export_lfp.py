import os
from pathlib import Path
from typing import Any, Union

import numpy as np
from debugpy.common.log import warning
from hdmf.data_utils import DataChunkIterator
from pynwb import NWBHDF5IO
from pynwb.base import TimeSeries
from pynwb.core import DynamicTableRegion
from pynwb.ecephys import ElectricalSeries, FilteredEphys
from pynwb.file import ProcessingModule
from scipy.io import loadmat

from nwb_utils.nwb_exporter import NWBExporter


def save_lfp_to_nwb(
    nwb_file: str,
    exp_file_path: Union[Path, str],
    electrode_table_region: DynamicTableRegion,
    channel_type: str = "LFP_micro",
) -> None:
    # Step 1: Set up file paths and load LFP data
    lfp_file_path = os.path.join(exp_file_path, channel_type)
    lfp_files = NWBExporter.list_files(lfp_file_path, "_lfp.mat", "._")
    lfp_timestamps_file = os.path.join(lfp_file_path, "lfpTimestamps.mat")

    # Load timestamps
    timestamps_start, sampling_rate = get_timestamps(lfp_timestamps_file)


    # Determine the maximum LFP length across files
    lfp_length = 0
    for lfp_file in lfp_files:
        lfp_data = loadmat(os.path.join(lfp_file_path, lfp_file))
        lfp_length = max(lfp_length, len(lfp_data["lfp"]))

    # Step 2: Load LFP data from the first file
    lfp = get_lfp(os.path.join(lfp_file_path, lfp_files[0]), lfp_length)

    # Step 3: Create the DataChunkIterator for compressed LFP data
    lfp_signal_compressed = DataChunkIterator(
        data=(lfp.reshape((1, -1))), buffer_size=1000
    )

    # Step 4: Create an ElectricalSeries object
    electrical_series = ElectricalSeries(
        name="ElectricalSeries",
        data=lfp_signal_compressed,
        electrodes=electrode_table_region,
        starting_time=timestamps_start,
        rate=sampling_rate,
        conversion=1e-6,  # volts
        unit="volts",
    )

    # Step 5: Create FilteredEphys object and add to the NWB file
    lfp_ephys = FilteredEphys(name=channel_type)
    lfp_ephys.add_electrical_series(electrical_series)

    with NWBHDF5IO(nwb_file, "r+") as nbw_io:
        nwb = nbw_io.read()

        if "ecephys" in nwb.processing:
            ecephys_module = nwb.processing["ecephys"]
        else:
            ecephys_module = ProcessingModule(
                name="ecephys", description="extracellular electrophysiology"
            )
            nwb.add_processing_module(ecephys_module)

        ecephys_module.add(lfp_ephys)
        nbw_io.write(nwb)

    # Step 6: Iteratively add remaining LFP channels
    with NWBHDF5IO(nwb_file, "r+") as nbw_io:
        nwb = nbw_io.read()
        electrical_series = nwb.processing["ecephys"][channel_type]["ElectricalSeries"]

        for lfp_file in lfp_files[1:]:
            lfp = get_lfp(os.path.join(lfp_file_path, lfp_file), lfp_length)
            electrical_series.data.append(lfp)

        nbw_io.write(nwb)

def get_timestamps(timestampsFile: str) -> Tuple[float, float]:

def get_lfp(lfp_file: str, lfp_length: int) -> np.ndarray[float, Any]:
    print(f"save LFP to nwb: {lfp_file}")
    lfp_data = loadmat(lfp_file)
    lfp = np.array(lfp_data["lfp"].flatten())

    if len(lfp) < lfp_length:
        warning(
            "LFP length not the same across channels, filling short signals with NaNs."
        )
        lfp = np.concatenate((lfp, np.full(lfp_length - len(lfp), np.nan)))  # type: ignore

    return lfp
