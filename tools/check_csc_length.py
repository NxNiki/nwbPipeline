"""
check the length of csc data to make sure they are same across channels.
check length of signal, timestamps and number of NaNs.
"""
import os.path
import warnings
from collections import defaultdict

import glob
import re
import pandas as pd
from typing import List
from functools import partial
import concurrent.futures

from src.utils.csc_reader import check_var_length
import logging


BASE_PATH = "/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/"
EXP_NAME = "MovieParadigm"

MAX_WORKERS = 8
SKIP_EXIST = True


def count_csc_length(file_path: str) -> None:

    # list timestamp files:
    timestamp_files = glob.glob(f"{file_path}/lfpTimeStamps*.mat")
    for timestamp_file in timestamp_files:
        suffix = re.search(r'.*lfpTimeStamps_(\d+).mat', timestamp_file)
        suffix = suffix.group(1)
        out_file = f"{file_path}/length_count_{suffix}.csv"
        if os.path.exists(out_file) and SKIP_EXIST:
            continue

        res = defaultdict(list)
        res['file_name'].append(timestamp_file)
        data_length, num_nans = check_var_length(timestamp_file, "timeStamps")
        res['data_length'].append(data_length)
        res['num_nans'].append(num_nans)

        csc_files = glob.glob(f"{file_path}/*_{suffix}.mat")
        csc_files = [f for f in csc_files if not os.path.basename(f).startswith("lfpTimeStamps")]

        check_var_length_job = partial(check_var_length, var_name="data")
        with concurrent.futures.ProcessPoolExecutor(max_workers=MAX_WORKERS) as executor:
            results = list(executor.map(check_var_length_job, csc_files))

        for i, (data_length, num_nans) in enumerate(results):
            res['file_name'].append(csc_files[i])
            res['data_length'].append(data_length)
            res['num_nans'].append(num_nans)

        length_count = pd.DataFrame(res)
        if len(length_count['data_length'].unique()) > 1:
            msg = f"inconsistent data length detected: {file_path}"
            print(msg)
            logging.critical(msg)
            out_file = out_file.replace(".csv", "error.csv")
        length_count.to_csv(out_file, index=False)


def list_path(patient_id: str) -> List[str]:

    patient_path = os.path.join(BASE_PATH, EXP_NAME, f"{patient_id}_{EXP_NAME}")
    logging.critical(f"check data length for patient {patient_id}...")

    res = glob.glob(f"{patient_path}/Experiment-*/CSC_macro")
    res += glob.glob(f"{patient_path}/Experiment-*/CSC_micro")
    return res


if __name__ == "__main__":

    # PATIENTS = ["562", "563", "566", "567", "568", "570", "571", "572", "573", "1717", "1728"]
    PATIENTS = ["564", "565", "574", "576", "577", "1677", "1702", "1714", "1720", "1721", "1741", "1764"]
    logging.basicConfig(
        filename=f'{BASE_PATH}/{EXP_NAME}/count_csc_length.log',
        filemode='a',
        level=logging.CRITICAL,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

    for patient_id in PATIENTS:
        data_paths = list_path(patient_id)
        for data_path in data_paths:
            count_csc_length(data_path)
