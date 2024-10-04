"""
create a table for each of selected patients listing the number of units for each channel.
The cluster information for each channel is saved in cluster_class in times file with two columns
(timestamps and cluster index from 0 to N).
make a single file with columns: patient_id, channel_name, N with 0, N without 0, num_channels.
"""
import glob
import os
import re
from collections import defaultdict
from typing import List, Tuple

import h5py
import numpy as np
import pandas as pd


def count_units_in_times_files(mat_files: List[str]) -> pd.DataFrame:
    """
    count number of units in times files in file path:
    :param file_path:
    :return:
    """
    unit_count = defaultdict(list)
    for mat_file in mat_files:
        channel_name = re.search(r"times_(.*?)\.mat", mat_file)
        if channel_name is None:
            continue

        unit_count["channel_name"].append(channel_name.group(1))
        mat_file_obj = h5py.File(mat_file, "r")
        cluster_class = np.array(mat_file_obj["cluster_class"])
        cluster_class = cluster_class[0, :]

        _, counts = np.unique(cluster_class, return_counts=True)
        unit_count["num_units_with_0"].append(len(counts))
        unit_count["units_count_with_0"].append(counts)

        _, counts = np.unique(cluster_class[cluster_class > 0], return_counts=True)
        unit_count["num_units"].append(len(counts))
        unit_count["units_count"].append(counts)

    return pd.DataFrame(unit_count)


def count_units(file_paths: List[Tuple[int, str]], output_path: str) -> pd.DataFrame:
    res = []
    for patient_id, file_path in file_paths:
        mat_files = glob.glob(os.path.join(file_path, "times_*.mat"))
        unit_count = count_units_in_times_files(mat_files)
        unit_count["num_channels"] = len(mat_files)
        unit_count.insert(0, "patient", patient_id)

        res.append(unit_count)

    unit_count = pd.concat(res, axis=0)
    unit_count.to_csv(os.path.join(output_path, "unit_count.csv"), index=False)
    return unit_count


if __name__ == "__main__":
    EXP_FILE_PATH = (
        "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening"
    )
    OUTPUT_PATH = "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/"
    FILE_PATH = [
        (
            577,
            f"{EXP_FILE_PATH}/577_Screening/Experiment-2/CSC_micro_spikes",
        ),
        (
            576,
            f"{EXP_FILE_PATH}/576_Screening/Experiment-2/CSC_micro_spikes",
        ),
        (
            574,
            f"{EXP_FILE_PATH}/574_Screening/Experiment-2/CSC_micro_spikes",
        ),
        (
            573,
            f"{EXP_FILE_PATH}/573_Screening/Experiment-1/CSC_micro_spikes",
        ),
        (
            571,
            f"{EXP_FILE_PATH}/571_Screening/Experiment-2/CSC_micro_spikes",
        ),
    ]

    count_units(FILE_PATH, OUTPUT_PATH)
