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

import pandas as pd
from neo.rawio.neuralynxrawio.nlxheader import NlxHeader


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


def read_channel_names(folder_path: str, file_pattern: str = "*.ncs") -> pd.DataFrame:
    """
    Reads the channel names from all files matching the specified pattern in a folder using neo.

    Parameters:
        folder_path (str): The path to the folder containing .ncs files.
        file_pattern (str): The pattern to match filenames (default: '*.ncs').

    Returns:
        dict: A dictionary where the keys are filenames and the values are channel names.
    """
    # Get all files matching the pattern in the folder
    file_names = glob.glob(os.path.join(folder_path, "*.ncs"))
    file_names = [f for f in file_names if re.match(file_pattern, os.path.basename(f))]

    channel_info_rows = []

    for file_path in file_names:
        file_name = os.path.basename(file_path)
        channel_name = file_name.replace(".ncs", "")
        channel_name = re.sub(r"_000[1-9]", "", channel_name)
        # Load each .ncs file with Neo
        header = NlxHeader(file_path, props_only=True)

        # skip micro channels:
        if header["sampling_rate"] > 2001:
            continue

        channel_name = header["channel_names"][0]
        channel_id = int(header["channel_ids"][0] + 1)
        channel_info_rows.append(
            {"channel_name": channel_name, "channel_id": channel_id}
        )

        # check_channel_name(file_name, channel_name, r"/([^/]+)\.ncs$")

    channel_info = pd.DataFrame(channel_info_rows).drop_duplicates()
    channel_info.sort_values(by="channel_id", ascending=True, inplace=True)
    channel_info.reset_index(inplace=True, drop=True)

    return channel_info


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


def create_channel_name_by_montage(csv_file: str) -> pd.DataFrame:
    print(f"generate channel name: {csv_file}")

    channel_names_rows = []
    with open(csv_file, "r", encoding="utf-8") as file:
        reader = csv.reader(file, delimiter="\t")
        # Skip the first row (header)
        next(reader)
        for row in reader:
            row = row[0].split(",")
            name = row[0]
            channel_id = int(row[1])
            count = int(row[4])

            if count == 1:
                channel_names_rows.append(
                    {"montage_channel_name": name, "montage_channel_id": channel_id}
                )
            else:
                for i in range(1, count + 1):
                    channel_names_rows.append(
                        {
                            "montage_channel_name": f"{name}{i}",
                            "montage_channel_id": int(channel_id + i - 1),
                        }
                    )

    channel_names = pd.DataFrame(channel_names_rows)
    channel_names.sort_values(by="montage_channel_id", ascending=True, inplace=True)
    channel_names.reset_index(inplace=True, drop=True)
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


def find_ncs_files(base_path: str, patient_id: int) -> Tuple[str, pd.DataFrame]:
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


def check_channels(
    channels_in_file: pd.DataFrame, channels_in_montage: pd.DataFrame
) -> pd.DataFrame:
    channels_combined = pd.merge(
        channels_in_montage,
        channels_in_file,
        left_on="montage_channel_id",
        right_on="channel_id",
        how="outer",
    )
    channels_combined["name_match"] = (
        channels_combined["channel_name"] == channels_combined["montage_channel_name"]
    )
    channels_combined["id_match"] = (
        channels_combined["channel_id"] == channels_combined["montage_channel_id"]
    )
    return channels_combined


def check_files(
    base_path: str,
    csv_files: List[str],
) -> None:
    for csv_file in csv_files:
        print(f"check: {csv_file}")
        patient_id = extract_patient_id(csv_file)
        _, file_names = find_ncs_files(base_path, patient_id)
        file_names_montage = create_channel_name_by_montage(csv_file)

        montage_file_path = os.path.dirname(csv_file)
        channel_names_combined = check_channels(file_names, file_names_montage)
        channel_names_combined.to_csv(
            os.path.join(montage_file_path, f"channel_names_combined_{patient_id}.csv")
        )


if __name__ == "__main__":
    EXCEL_FILE = "/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Clinical Montages/clinical_montages.xlsx"
    NCS_FILE_PATH = "/Volumes/DATA/NLData/"

    montage_files = split_xls_file(EXCEL_FILE)
    check_files(NCS_FILE_PATH, montage_files)
