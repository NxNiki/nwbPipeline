"""
This script checks channel names of macro files from the Neuralynx system.

The macro files may be incorrectly named due to mistake in the config file. This script will read the digitized montage
file (.csv). And confirm the channel name in .ncs file is consistent to what is expected from the montage file.

This script will create two files in the montage folder if there are unmatched channels:
<patient_id>_file_unmatch.csv has files that does not have corresponding channels in the montage file.
<patient_id>_montage_unmatch.csv has channels that does not have corresponding files in the Neuralynx directory.
"""

import csv
import glob
import os
import re
from typing import Dict, List, Tuple

import neo
import pandas as pd


def split_xls_file(file_name: str, overwrite: bool = False) -> List[str]:
    path = os.path.dirname(file_name)
    # Read all sheets into a dictionary of dataframes
    sheets_dict = pd.read_excel(file_name, sheet_name=None)

    # Iterate over the dictionary and save each sheet as a separate .csv file
    csv_files = []
    for sheet_name, sheet_data in sheets_dict.items():
        # Create a CSV filename for each sheet
        csv_file = f"{path}/{sheet_name}.csv"

        # Save the dataframe to CSV
        if not os.path.exists(csv_file) or overwrite:
            sheet_data.to_csv(csv_file, index=False)
            print(f'Sheet "{sheet_name}" has been saved as "{csv_file}"')

        if re.match(r"\d+", sheet_name):
            csv_files.append(csv_file)

    return csv_files


def read_channel_names(
    folder_path: str, file_pattern: str = "*.ncs", check_header: bool = False
) -> List[str]:
    """
    Reads the channel names from all files matching the specified pattern in a folder using neo.

    Parameters:
        folder_path (str): The path to the folder containing .ncs files.
        file_pattern (str): The pattern to match filenames (default: '*.ncs').
        check_header (bool):

    Returns:
        dict: A dictionary where the keys are filenames and the values are channel names.
    """
    # Get all files matching the pattern in the folder
    file_names = glob.glob(os.path.join(folder_path, "*.ncs"))
    file_names = [f for f in file_names if re.match(file_pattern, os.path.basename(f))]

    # Dictionary to store the channel names
    channel_names = set([])

    for file_path in file_names:
        file_name = os.path.basename(file_path)
        channel_name = file_name.replace(".ncs", "")
        channel_name = re.sub(r"_000[1-9]", "", channel_name)
        channel_names.add(channel_name)
        if check_header:
            # Load each .ncs file with Neo
            reader = neo.io.NeuralynxIO(
                dirname=folder_path, include_filenames=file_name
            )
            header = reader.header

            # Extract the channel name from the signal channels metadata
            signal_channels = header.get("signal_channels", [])
            if len(signal_channels) > 0:
                channel_name = signal_channels["name"][0]
                check_channel_name(file_name, channel_name, r"/([^/]+)\.ncs$")

    return sorted(list(channel_names))


def check_channel_name(file_name: str, channel_name: str, regex_pattern: str) -> bool:
    """
    Checks if file_name and channel_name match, based on a regular expression pattern.
    """

    # Compile the regular expression pattern
    pattern = re.compile(regex_pattern)

    print(f"file: {file_name}, channel: {channel_name}")
    # Extract the string from the key using the regex pattern
    match = pattern.search(file_name)
    res = False
    if match and match.group(0) == channel_name:
        res = True
    return res


def create_channel_name_by_montage(csv_file: str) -> List[str]:
    channel_names = []
    print(f"generate channel name: {csv_file}")

    with open(csv_file, "r", encoding="utf-8") as file:
        reader = csv.reader(file, delimiter="\t")
        # Skip the first row (header)
        next(reader)
        for row in reader:
            row = row[0].split(",")
            name = row[0]
            count = int(row[4])

            if count == 1:
                channel_names.append(name)
            else:
                for i in range(1, count + 1):
                    channel_names.append(f"{name}{i}")

    return channel_names


def compare_lists(list1: List[str], list2: List[str]) -> Tuple[List[str], List[str]]:
    """list channels names does not exist in the other"""
    list1 = [clean_channel_name(l) for l in list1]
    list2 = [clean_channel_name(l) for l in list2]

    set1 = set(list1)
    set2 = set(list2)

    list1_not_in_list2 = list(set1 - set2)
    list2_not_in_list1 = list(set2 - set1)

    return list1_not_in_list2, list2_not_in_list1


def clean_channel_name(channel_name: str) -> str:
    channel_name = channel_name.replace("-", "")
    channel_name = channel_name.upper()

    return channel_name


def extract_patient_id(file_path: str) -> int:
    # Define the regex pattern to capture numbers before ".csv"
    match = re.search(r"/(\d+)\.csv$", file_path)

    if match:
        return int(match.group(1))  # Extract the first capture group as an integer
    raise ValueError("No number found in the given file path")


def find_ncs_files(base_path: str, patient_id: int) -> Tuple[str, List[str]]:
    ncs_file_pattern = [
        f"{base_path}/D{patient_id}/EXP?_Screening/202[3,4]-*/",
        f"{base_path}/D{patient_id}/EXP2_*/202[3,4]-*/",
        f"{base_path}/D{patient_id}/EXP1_*/202[3,4]-*/",
        f"{base_path}/D{patient_id}/EXP?_*/202?-*/",
    ]

    ncs_path = ""
    for pattern in ncs_file_pattern:
        ncs_paths = glob.glob(pattern)
        if len(ncs_paths) > 0:
            ncs_path = ncs_paths[0]
            break

    # use file pattern to exclude micro channels (G[A-D][1-9]_*.ncs):
    channel_names = read_channel_names(ncs_path, r"^(?!G[A-D][1-9]_*).*?[0-9]\.ncs$")
    return ncs_path, channel_names


def save_list(strings: List[str], file_name: str) -> None:
    strings.sort()
    with open(file_name, mode="w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        for string in strings:
            writer.writerow([string])


def check_files(base_path: str, csv_files: List[str]) -> None:
    for csv_file in csv_files:
        print(f"check: {csv_file}")
        patient_id = extract_patient_id(csv_file)
        file_path, file_names = find_ncs_files(base_path, patient_id)
        ncs_files_csv = create_channel_name_by_montage(csv_file)

        file_unmatch, montage_unmatch = compare_lists(file_names, ncs_files_csv)
        if file_unmatch:
            print(f"unmatched .ncs file: {file_unmatch}")
            file_unmatch = [os.path.join(file_path, f) for f in file_unmatch]
            save_list(file_unmatch, csv_file.replace(".csv", "_file_unmatch.csv"))
        if montage_unmatch:
            print(f"unmatched montage channel: {montage_unmatch}")
            save_list(montage_unmatch, csv_file.replace(".csv", "_montage_unmatch.csv"))


if __name__ == "__main__":
    EXCEL_FILE = "/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Clinical Montages/clinical_montages.xlsx"
    NCS_FILE_PATH = "/Volumes/DATA/NLData/"

    montage_files = split_xls_file(EXCEL_FILE)
    check_files(NCS_FILE_PATH, montage_files)
