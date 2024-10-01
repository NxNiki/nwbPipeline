import os

import neo
from neo.rawio.neuralynxrawio.nlxheader import NlxHeader

FILE_NAME = "A1.ncs"
FOLDER_PATH = "neuralynx/raw"
reader = neo.io.NeuralynxIO(dirname=FOLDER_PATH, include_filenames=FILE_NAME)
header = reader.header
signal_channels = header.get("signal_channels", [])
print(signal_channels["name"])
print(signal_channels["sampling_rate"])

FILE_NAME = "A1.ncs"
file_path = os.path.join(FOLDER_PATH, FILE_NAME)
header = NlxHeader(file_path, props_only=True)
print(header)
print(header["channel_ids"])
