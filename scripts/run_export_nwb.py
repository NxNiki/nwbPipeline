import os

from pynwb import NWBHDF5IO, NWBFile

DEVICE = "Neuralynx Pegasus"
MANUFACTURER = "Neuralynx"
# Provide default DEFAULT_DATE to protect PHI. Note: It is not the ACTUAL DEFAULT_DATE of the experiment

exp_ids = range(3, 12)
EXP_NAME = "MovieParadigm"
PATIENT_ID = 573

# Set up paths
script_dir = os.path.dirname(os.path.abspath(__file__))
file_path = f"/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/{EXP_NAME}/{PATIENT_ID}_{EXP_NAME}"
exp_file_path = os.path.join(file_path, f'Experiment-{"-".join(map(str, exp_ids))}')

# Initialize NWB file
