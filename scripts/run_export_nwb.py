import os
from datetime import datetime

from pynwb import NWBHDF5IO, NWBFile
from pynwb.file import Subject

DEVICE = "Neuralynx Pegasus"
MANUFACTURER = "Neuralynx"
# Provide default DEFAULT_DATE to protect PHI. Note: It is not the ACTUAL DEFAULT_DATE of the experiment
DEFAULT_DATE = "1900-01-01"

exp_ids = range(3, 12)
EXP_NAME = "MovieParadigm"
PATIENT_ID = 573

# Set up paths
script_dir = os.path.dirname(os.path.abspath(__file__))
file_path = f"/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/{EXP_NAME}/{PATIENT_ID}_{EXP_NAME}"
exp_file_path = os.path.join(file_path, f'Experiment-{"-".join(map(str, exp_ids))}')
out_file_path = os.path.join(exp_file_path, "nwb")
out_nwb_file = os.path.join(out_file_path, "ecephys.nwb")

if not os.path.exists(out_file_path):
    os.makedirs(out_file_path)

# Initialize NWB file
session_start_time = datetime.strptime(DEFAULT_DATE, "%Y-%m-%d")

nwb = NWBFile(
    session_description=f'sub-{PATIENT_ID}_exp-{"_".join(map(str, exp_ids))}_{EXP_NAME}',
    identifier=f'sub-{PATIENT_ID}_exp-{"_".join(map(str, exp_ids))}_{EXP_NAME}',
    session_start_time=session_start_time,
    timestamps_reference_time=session_start_time,
    experimenter="My Name",  # optional
    institution="UCLA",  # optional
    related_publications="",  # optional
)

nwb.subject = Subject(
    subject_id=str(PATIENT_ID), age="", description="", species="human", sex="M"
)

# Save the NWB file
with NWBHDF5IO(out_nwb_file, "w") as io:
    io.write(nwb)
