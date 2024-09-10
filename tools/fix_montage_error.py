"""
This script corrects file names created according to montage with mistake.
One additional electrode was added to the montage file which does not exist,
resulting in one additional file in result folder after that electrode.

This script will rename files in folder with pattern *EXP* for subject 568.

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


def rename_directory(directory: str) -> str:
    directory_split = directory.split("/")

    pattern = r"^EXP.*"
    # Find the first index of the string that matches the pattern
    first_match_index = next(
        (i for i, s in enumerate(directory_split) if re.match(pattern, s)), -1
    )
    # add suffix to the parent folder of folder with pattern "^EXP.*':
    first_match_index = first_match_index - 1
    directory_split[first_match_index] = directory_split[first_match_index] + "_renamed"

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
            logging.warning("missing file: %s/%s.ncs", directory, file_error)
            continue

        for file_name in files_error:
            match = re.search(r"_\d{3,5}.ncs", file_name)
            if match:
                suffix = match.group()
                file_correct = file_correct + suffix

            # skip file if already copied:
            if SKIP_EXISTING_FILES and os.path.exists(
                f"{dir_renamed}/{file_correct}.ncs"
            ):
                logging.info(
                    "skip existing file: %s", f"{dir_renamed}/{file_correct}.ncs"
                )
                continue

            try:
                shutil.copyfile(file_name, f"{dir_renamed}/{file_correct}.ncs")
                logging.info(
                    "copy: %s to %s/%s.ncs on dir: %s",
                    file_name,
                    dir_renamed,
                    file_correct,
                    directory,
                )
            except OSError as err:
                print(f"Error copying {file_name}: {err}")
                logging.error("Error copying %s: %s", file_name, err)


def correct_file_name(
    file_directory: str,
    montage_correct: List[Tuple[str, int]],
    montage_error: List[Tuple[str, int]],
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

    file_name_correct = generate_file_name(montage_correct)
    file_name_error = generate_file_name(montage_error)

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

        if re.match(r"" + file_directory + "*EXP*", sub_dir):
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
    # file_directory = r'/Users/xinniu/Library/CloudStorage/Box-Box/Vwani_Movie/568/'
    FILE_DIRECTORY = "/Volumes/DATA/NLData/D568_fix_name/"

    # Putting 'PZ' at top so that files for this channel is not renamed.
    MONTAGE_ERROR = [
        ("PZ", 1),
        ("RMH", 8),
        ("RA", 9),
        ("RAC", 8),
        ("ROF", 8),
        ("ROPRAI", 7),  # should be 6
        ("RpSMAa", 7),
        ("RpSMAp", 7),
        ("RMF", 8),
        ("LA", 9),
        ("LAH", 8),
        ("LAC", 9),
        ("LOF", 8),
        ("LAI", 7),
        ("LpSMA", 7),
    ]
    MONTAGE_CORRECT = [
        ("PZ", 1),
        ("RMH", 8),
        ("RA", 9),
        ("RAC", 8),
        ("ROF", 8),
        ("ROPRAI", 6),
        ("RpSMAa", 7),
        ("RpSMAp", 7),
        ("RMF", 8),
        ("LA", 9),
        ("LAH", 8),
        ("LAC", 9),
        ("LOF", 8),
        ("LAI", 7),
        ("LpSMA", 7),
    ]

    correct_file_name(FILE_DIRECTORY, MONTAGE_CORRECT, MONTAGE_ERROR)
