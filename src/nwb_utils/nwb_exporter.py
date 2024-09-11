import os.path
import re
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
from uuid import uuid4

from create_nwb import create_nwb
from dateutil import tz
from pynwb import NWBHDF5IO, NWBFile
from requests import session


class NWBExporter(NWBFile):  # type: ignore
    """
    Export spike time, mean spike waveform, filtered LFP for micro and macro channels to nwb data.
    """

    def __init__(
        self,
        data_file_path: Union[str, Path],
        session_description: Optional[str] = None,
        session_id: Optional[str] = None,
        **kwargs: Dict[str, Any],
    ) -> None:
        """
        Initialize the NWBExporter, inheriting from NWBFile.

        Parameters:
        - session_description (str): Description of the experimental session.
        - identifier (str): Unique identifier for the NWB file.
        - session_start_time (datetime): Start time of the session.
        - **kwargs: Additional keyword arguments for NWBFile.
        """
        if session_description is None:
            session_description = "MovieParadigm"
        if session_id is None:
            session_id = "session_1"

        session_start_time = datetime(
            1900, 1, 1, 0, 0, 0, tzinfo=tz.gettz("US/Pacific")
        )
        lab = "CNL"
        institution = "UCLA"
        identifier = str(uuid4())

        super().__init__(
            session_description=session_description,
            identifier=identifier,
            session_id=session_id,
            session_start_time=session_start_time,
            lab=lab,
            institution=institution,
            **kwargs,
        )

        self.data_file_path = data_file_path
        self.out_file_path = os.path.join(data_file_path, "nwb")
        self.out_nwb_file = os.path.join(self.out_file_path, "ecephys.nwb")

        if not os.path.exists(self.out_file_path):
            os.makedirs(self.out_file_path)

        nwb = create_nwb(self.data_file_path)
        # Save the NWB file
        with NWBHDF5IO(self.out_nwb_file, "w") as nwb_io:
            nwb_io.write(nwb)

    @property
    def spike_file_path(self) -> str:
        return os.path.join(self.data_file_path, "CSC_micro_spikes")

    @property
    def micro_lfp_path(self) -> str:
        return os.path.join(self.data_file_path, "micro_lfp")

    @property
    def macro_lfp_path(self) -> str:
        return os.path.join(self.data_file_path, "macro_lfp")

    @property
    def nwb_path(self) -> str:
        return os.path.join(self.data_file_path, "nwb")

    @staticmethod
    def get_repo_root() -> Path:
        """
        Returns the root directory of the repository.
        """
        current_file = Path(__file__).resolve()
        repo_root = current_file.parent
        return repo_root

    @staticmethod
    def list_files(
        directory: Union[str, Path], pattern: str = ".*", exclude_pattern: str = ""
    ) -> List[str]:
        """
        List files in a directory matching a given pattern and excluding those matching the exclude pattern.
        """
        return [
            f
            for f in os.listdir(directory)
            if re.match(pattern, f) and not re.match(exclude_pattern, f)
        ]

    def add_metadata(self, metadata_key: str, metadata_value: Any) -> None:
        """
        Add custom metadata to the NWB file.

        Parameters:
        - metadata_key (str): The key/name of the metadata.
        - metadata_value (str): The value of the metadata.
        """
        self.general.set(metadata_key, metadata_value)

    def get_metadata(self, metadata_key: str) -> Any:
        """
        Retrieve custom metadata from the NWB file.

        Parameters:
        - metadata_key (str): The key/name of the metadata to retrieve.

        Returns:
        - metadata_value (str): The value of the metadata.
        """
        return self.general.get(metadata_key, None)

    def save_to_file(self, file_path: Union[str, Path]) -> None:
        """
        Save the NWB file to disk.

        Parameters:
        - file_path (str): The path where the NWB file will be saved.
        """
        with NWBHDF5IO(file_path, "w") as nwb_io:
            nwb_io.write(self)
        print(f"NWB file saved to {file_path}")

    @classmethod
    def load_from_file(cls, file_path: Union[str, Path]) -> NWBFile:
        """
        Load an NWB file from disk and return an instance of NWBExporter.

        Parameters:
        - file_path (str): The path to the NWB file to load.

        Returns:
        - instance of NWBExporter
        """
        with NWBHDF5IO(file_path, "r") as nwb_io:
            nwbfile = nwb_io.read()
            instance = cls(
                data_file_path=file_path,
                session_description=nwbfile.session_description,
                identifier=nwbfile.identifier,
                session_start_time=nwbfile.session_start_time,
                institution=nwbfile.institution,
            )
            # Copy over all attributes from the loaded NWB file
            instance.__dict__.update(nwbfile.__dict__)
        return instance

    def display_summary(self) -> None:
        """
        Display a summary of the NWB file, including custom metadata.
        """
        print(f"Session Description: {self.session_description}")
        print(f"Identifier: {self.identifier}")
        if self.general:
            print("General Metadata:")
            for key, value in self.general.items():
                print(f"  {key}: {value}")


# Example usage:
if __name__ == "__main__":
    test_path = NWBExporter.get_repo_root() / "test/neuralynx"
    # Create an instance of NWBExporter
    exporter = NWBExporter(
        data_file_path=test_path,
        session_description="Test session",
    )

    # Add custom metadata
    exporter.add_metadata("experiment_type", "Visual Cortex Study")

    # Save the NWB file
    exporter.save_to_file("example_nwb_file.nwb")

    # Load the NWB file
    loaded_exporter = NWBExporter.load_from_file("example_nwb_file.nwb")

    # Display a summary
    loaded_exporter.display_summary()
