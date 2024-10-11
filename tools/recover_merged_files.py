"""
PDM merge .ncs files when there are multiple sessions and save results in one file. This leads to NaNs if there is a gap
between sessions. We plan to save sessions separately in nwbPipeline. This module find files that are merged (still
saved separately in folder 'suffix0*'). Move files to the parent folder and (optional) remove the combined files to save
storage space.
"""

import shutil
import csv
from pathlib import Path
from typing import List, Union

def list_files_with_suffix(directory: Union[str, Path], pattern: str, result_name: str) -> List[Path]:
    """List all files matching the pattern 'suffix*'."""
    if isinstance(directory, str):
        directory = Path(directory)

    res = [path for path in directory.rglob(f'{pattern}*')]
    # Writing the list to a CSV file
    with open(result_name, 'w', newline='') as file:
        writer = csv.writer(file)
        for item in res:
            writer.writerow([str(item)])  # Write each item as a row

    return res


def move_ncs_files_to_parent(file_paths: List[Path]) -> None:
    """Move only .ncs files from the list to the parent directory."""
    for path in file_paths:
        parent_dir = path.parent
        for ncs_file in path.glob('*.ncs'):  # Look for .ncs files in the directory
            try:
                shutil.move(str(ncs_file), str(parent_dir / ncs_file.name))
                print(f"Moved: {ncs_file} to {parent_dir}")
            except Exception as e:
                print(f"Error moving {ncs_file}: {e}")


if __name__ == '__main__':
    directory = '/Volumes/DATA/NLData/'
    suffix_pattern = 'suffix0'  # The pattern to match

    # Step 1: List all files matching 'suffix*'
    matching_files: List[Path] = list_files_with_suffix(directory, suffix_pattern, 'merged_directories.csv')

    # Step 2: Move only the .ncs files
    # move_ncs_files_to_parent(matching_files)
