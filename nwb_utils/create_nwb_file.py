import os
import re
from typing import List, Tuple

from hdmf.common import DynamicTable, DynamicTableRegion
from hdmf.utils import docval, get_docval, popargs
from pynwb import NWBHDF5IO, NWBFile
from pynwb.core import DynamicTable as NWBDynamicTable
from pynwb.device import Device
from pynwb.ecephys import ElectrodeGroup

from nwb_utils.nwb_exporter import NWBExporter


def create_electrode_table(
    nwb_file: NWBFile, exp_file_path: str
) -> Tuple[DynamicTableRegion, DynamicTableRegion]:
    """
    Create electrode table based on file names of micro and macro channels.
    Micro channels have pattern: G[A-D][1-8]_[A-Z]+[1-8]_lfp.mat
    Macro channels have pattern: [A-Z]+[1-8]_lfp.mat
    """
    lfp_file_path = os.path.join(exp_file_path, "LFP_micro")
    micro_lfp_files = NWBExporter.list_files(lfp_file_path, r".*_lfp\.mat$", r"^\.")

    lfp_file_path = os.path.join(exp_file_path, "LFP_macro")
    macro_lfp_files = NWBExporter.list_files(lfp_file_path, r".*_lfp\.mat$", r"^\._")

    if not micro_lfp_files and not macro_lfp_files:
        raise UserWarning(f"No LFP files detected in {exp_file_path}!")

    print(
        f"create_electrode_table: total of {len(micro_lfp_files)} micro LFP files detected"
    )
    print(
        f"create_electrode_table: total of {len(macro_lfp_files)} macro LFP files detected"
    )

    with NWBHDF5IO(nwb_file, "r+") as nwb_io:
        nwb = nwb_io.read()

        add_electrodes(nwb, micro_lfp_files)
        add_electrodes(nwb, macro_lfp_files)

        if micro_lfp_files:
            electrode_table_region_micro = DynamicTableRegion(
                name="micro_electrodes",
                data=list(range(len(micro_lfp_files))),
                description="micro electrodes",
                table=nwb.electrodes,
            )
        else:
            electrode_table_region_micro = None

        if macro_lfp_files:
            electrode_table_region_macro = DynamicTableRegion(
                name="macro_electrodes",
                data=list(range(len(micro_lfp_files), len(macro_lfp_files))),
                description="macro electrodes",
                table=nwb.electrodes,
            )
        else:
            electrode_table_region_macro = None

    # Save the NWB file
    with NWBHDF5IO(nwb_file, "w") as nwb_io:
        nwb_io.write(nwb)

    return electrode_table_region_micro, electrode_table_region_macro


def add_electrodes(nwb: NWBFile, lfp_files: List[str]) -> None:
    """
    Add electrodes to electrodes_table. Determine whether the file is macro or macros by the file name.

    :param nwb:
    :param lfp_files:
    :return:
    """
    pattern = r"(G[A-D][1-8])|([A-Z]+[1-8])"
    shank_label_added = []
    for lfp_file in lfp_files:
        lfp_file_name = os.path.splitext(lfp_file)[0]
        matches = re.findall(pattern, lfp_file_name)

        if len(matches) == 2:
            shank_label = matches[0][0]
            electrode_label = matches[1][1]
        else:
            shank_label = "macro"
            electrode_label = matches[0][1]

        location = re.findall(r"[A-Z]+", electrode_label)[0]

        if shank_label not in shank_label_added:
            egroup = ElectrodeGroup(
                name=shank_label,
                description=f"electrode group for {shank_label}",
                location=location,
                device=None,  # Add the appropriate device if necessary
            )
            nwb.add_electrode_group(egroup)
            shank_label_added.append(shank_label)
        else:
            egroup = nwb.get_electrode_group(shank_label)

        # Add the electrode directly to the nwb file, which will initialize the electrodes table if needed
        nwb.add_electrode(
            x=111,
            y=111,
            z=111,
            location=location,
            group=egroup,
            group_name=shank_label,
            label=electrode_label,
        )
