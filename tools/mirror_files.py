"""
copy files on hoffman to Box. TODO: use boxsdk to mirror files.
"""
import os
import glob
import shutil
from tqdm import tqdm

# patients = [562, 563, 566, 567, 568, 570, 572, 573, 1717, 1728]
patients = [572, 573, 1717, 1728]
folders = ['Audio', 'CSC_macro', 'TTLs']
source_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm'
dest_path = '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Vwani_Movie/MovieParadigm'

def copy_files(patients, folders, source_path):
    for patient in tqdm(patients, desc="copy files for patient"):
        for folder in folders:
            source_folders = glob.glob(os.path.join(source_path, f"{patient}_MovieParadigm", "Experiment-*", folder))
            for source_folder in tqdm(source_folders, desc="folder", leave=True):
                destination_folder = source_folder.replace(source_path, dest_path)
                print(f"copy: {source_folder}")
                print(f"to: {destination_folder}")
                shutil.copytree(source_folder, destination_folder)


if __name__ == "__main__":
    copy_files(patients, folders, source_path)