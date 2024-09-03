from pynwb import NWBHDF5IO
from pynwb.file import Subject


def save_subject(nwb_file: str, patient_id: int) -> None:
    with NWBHDF5IO(nwb_file, "r+") as nwb_io:
        nwb = nwb_io.read()
        nwb.subject = Subject(
            subject_id=str(patient_id), age="", description="", species="human", sex="M"
        )

    with NWBHDF5IO(nwb_file, "w") as nwb_io:
        nwb_io.write(nwb)
