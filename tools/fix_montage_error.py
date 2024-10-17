"""
This script corrects file names created according to montage information.
Sometimes the number of macro channels for a region is not correctly configured
resulting in incorrect channel names for macro .ncs file.

This script will rename files in folder with pattern *EXP* for specific patient.

Example:
    correct file: [A1, A2, A3, B1, B2, B3, C1, C2, ...]
    error file:   [A1, A2, A3, B1, B2, B3, B4, C1, C2, ...]

B4 is renamed to C1, C1 renamed to C2, etc.
"""

import datetime
import glob
import logging
import os
import re
import shutil
from typing import List, Tuple, Union

import pandas as pd

SKIP_EXISTING_FILES = True
FILE_SUFFIX = ".ncs"


def generate_file_name(montage: List[Tuple[str, int]]) -> List[str]:
    file_name = []
    for tag, count in montage:
        if count > 1:
            file_name.extend([tag + str(i) for i in range(1, count + 1)])
        else:
            file_name.extend([tag])
    return file_name


# pylint: disable=all
def read_montage_correction_file(file_name: str) -> Tuple[List[str], List[str]]:
    """read montage correction file and generate file names with corresponding correct file names.
    The montage correction file has three columns:
        channel_name
        num_channel_error
        num_channel_correct

    :param file_name:
    :return:
    """
    montage_correction = pd.read_csv(file_name, delimiter="\t", index_col=None)
    return [], []


def read_montage_comparison_file(
    file_name: str, montage_channel_col: str, actual_channel_col: str
) -> Tuple[List[str], List[str]]:
    montage_comparison = pd.read_csv(file_name, delimiter=",", index_col=None)
    montage_comparison = montage_comparison[[montage_channel_col, actual_channel_col]]
    montage_comparison.dropna(how="any", inplace=True)
    return (
        montage_comparison[montage_channel_col].to_list(),
        montage_comparison[actual_channel_col].to_list(),
    )


def rename_directory(directory: str) -> str:
    directory_split = directory.split("/")

    pattern = r"^EXP.*"
    # Find the first index of the string that matches the pattern
    first_match_index = next(
        (i for i, s in enumerate(directory_split) if re.match(pattern, s)), -1
    )
    # add suffix to the parent folder of folder with pattern "^EXP.*":
    first_match_index = first_match_index - 1
    directory_split[first_match_index] = (
        directory_split[first_match_index] + "_macro_renamed"
    )

    directory_rename = "/".join(directory_split)
    return directory_rename


def copy_files(directory: str, file_pattern: str, dest_directory: str) -> None:
    """
    copy files that match pattern in directory to dest_directory.
    :param directory:
    :param file_pattern:
    :param dest_directory:
    :return:
    """

    files = glob.glob(os.path.join(directory, file_pattern))
    for file_name in files:
        base_name = os.path.basename(file_name)
        dest_file = os.path.join(dest_directory, base_name)
        if SKIP_EXISTING_FILES and os.path.exists(dest_file):
            logging.info("skip existing file: %s\n", dest_file)
            continue

        shutil.copyfile(file_name, dest_file)
        logging.info(
            "copy file: %s \nfrom: %s \nto: %s\n", file_name, directory, dest_directory
        )


def list_sub_dirs_with_files(folder_path: str, file_ext: str) -> List[str]:
    sub_dirs = []

    # Loop through all subdirectories
    for root, _, _ in os.walk(folder_path):
        # do not list files in renamed folder
        if re.match(r".*_renamed", root):
            continue
        # Check if any files exist in the current directory
        ncs_files = glob.glob(os.path.join(root, f"*{file_ext}"))
        if ncs_files:
            sub_dirs.append(root)

    return sub_dirs


def rename_files(
    directory: str,
    file_name_correct: List[str],
    file_name_error: List[str],
) -> None:
    """
    copy files to a new directory and correct file names.

    :param directory:
    :param file_name_correct:
    :param file_name_error:
    :return:
    """
    dir_renamed = rename_directory(directory)

    for file_error, file_correct in zip(file_name_error, file_name_correct):
        files_error = glob.glob(f"{directory}/{file_error}*")
        # skip if file does not exist in source:
        if len(files_error) == 0:
            logging.warning("missing file:%s in directory: %s", file_error, directory)
            continue

        for file_name in files_error:
            match = re.search(r"_\d{3,5}.ncs", file_name)
            if match:
                suffix = match.group()
                file_correct_suffix = file_correct + suffix
            else:
                file_correct_suffix = file_correct + ".ncs"

            dest_file = os.path.join(dir_renamed, file_correct_suffix)
            # skip file if already copied:
            if SKIP_EXISTING_FILES and os.path.exists(dest_file):
                logging.info("skip existing file: %s", dest_file)
                continue

            try:
                shutil.copyfile(file_name, dest_file)
                if file_error == file_correct:
                    logging.info("copy: %s \nto: %s", file_name, dest_file)
                else:
                    logging.warning("copy: %s \nto: %s", file_name, dest_file)

            except OSError as err:
                print(f"Error copying {file_name}: {err}")
                logging.error("Error copying %s: %s", file_name, err)


def correct_file_name(
    file_directory: str,
    file_name_correct: List[str],
    file_name_error: List[str],
) -> None:
    current_datetime = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M")
    log_file = os.path.join(
        file_directory, f"log_fix_montage_error_{current_datetime}.log"
    )
    logging.basicConfig(
        filename=log_file,
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )

    sub_directories = list_sub_dirs_with_files(file_directory, ".ncs")
    for sub_dir in sub_directories:
        logging.info(
            "sub_dir: %s",
            sub_dir,
        )
        sub_dir_renamed = rename_directory(sub_dir)

        # create directory if not exists and not a file (end with .xxx).
        if not os.path.exists(sub_dir_renamed) and not re.search(
            r"\..*", sub_dir_renamed
        ):
            os.makedirs(sub_dir_renamed)

        if re.match(r"" + file_directory + ".*EXP.*", sub_dir):
            # copy macro files in the directory with file names corrected:
            rename_files(sub_dir, file_name_correct, file_name_error)

            # copy micro channels:
            # copy_files(sub_dir, "G[A-D]*.ncs", sub_dir_renamed)

            # copy event files:
            # copy_files(sub_dir, "*.nev", sub_dir_renamed)
        else:
            # try to copy all files without correcting file names:
            try:
                if os.path.isdir(sub_dir):
                    shutil.copytree(sub_dir, sub_dir_renamed, dirs_exist_ok=True)
                    logging.info("copy directory: %s to %s}", sub_dir, sub_dir_renamed)
                else:
                    shutil.copyfile(sub_dir, sub_dir_renamed)
                    logging.info("copy file: %s to %s", sub_dir, sub_dir_renamed)
            except OSError as err:
                print(f"Error copying {sub_dir}: {err}")
                logging.error("Error copying %s: %s", sub_dir, err)


if __name__ == "__main__":
    FILE_DIRECTORY = "/Volumes/DATA/NLData/D568"
    MONTAGE_COMPARISON_FILE = (
        "/Volumes/DATA/NLData/D568/channel_names_combined_568_macro_error_fix.csv"
    )

    _file_name_correct, _file_name_error = read_montage_comparison_file(
        MONTAGE_COMPARISON_FILE, "rename_channel", "channel_name"
    )

    correct_file_name(FILE_DIRECTORY, _file_name_correct, _file_name_error)
