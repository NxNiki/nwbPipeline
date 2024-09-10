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
    directory_split[-2] = directory_split[-2] + "_renamed"

    directory_rename = "/".join(directory_split)
    return directory_rename


def rename_files(
    sub_dir: str,
    sub_dir_renamed: str,
    file_name_correct: List[str],
    file_name_error: List[str],
) -> None:
    for file_error, file_correct in zip(file_name_error, file_name_correct):
        # skip file if already copied:
        if SKIP_EXISTING_FILES and os.path.exists(
            f"{sub_dir_renamed}/{file_correct}.ncs"
        ):
            continue

        files_error = glob.glob(f"{sub_dir}/{file_error}*")
        # skip if file does not exist in source:
        if len(files_error) == 0:
            logging.info("missing file: %s/%s.ncs", sub_dir, file_error)
            continue

        if len(files_error) > 1:
            logging.warning(
                "multiple files found with pattern: %s/%s. Only first one is copied",
                sub_dir,
                file_error,
            )
        file_error_full_path = files_error[0]
        try:
            shutil.copyfile(
                file_error_full_path, f"{sub_dir_renamed}/{file_correct}.ncs"
            )
            if file_error != file_correct:
                logging.info(
                    "rename: %s to %s/%s.ncs on dir: %s",
                    file_error_full_path,
                    sub_dir_renamed,
                    file_correct,
                    sub_dir,
                )
            else:
                logging.info(
                    "copy: %s to %s/%s.ncs on dir: %s",
                    file_error_full_path,
                    sub_dir_renamed,
                    file_correct,
                    sub_dir,
                )
        except OSError as err:
            print(f"Error copying {file_error_full_path}: {err}")
            logging.error("Error copying %s: %s", file_error_full_path, err)


def correct_file_name(
    file_directory: str,
    montage_correct: List[Tuple[str, int]],
    montage_error: List[Tuple[str, int]],
) -> None:
    current_datetime = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M")
    logging.basicConfig(
        filename=f"log_fix_montage_error_{current_datetime}.log",
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )

    file_name_correct = generate_file_name(montage_correct)
    file_name_error = generate_file_name(montage_error)

    sub_directories = glob.glob(file_directory + "*")
    for sub_dir in sub_directories:
        sub_dir_renamed = rename_directory(sub_dir)

        # create directory if not exists and not a file (end with .xxx).
        if not os.path.exists(sub_dir_renamed) and not re.search(
            r"\..*", sub_dir_renamed
        ):
            os.makedirs(sub_dir_renamed)

        if re.match(r"" + file_directory + "EXP*", sub_dir):
            rename_files(sub_dir, sub_dir_renamed, file_name_correct, file_name_error)
        else:
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
    FILE_DIRECTORY = (
        r"/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/568_MovieParadigm/"
        r"Experiment-4/CSC_macro"
    )

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
