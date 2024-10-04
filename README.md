# nwbPipeline
Data processing pipeline for iEEG (Neuralynx and Blackrock) recordings.

- [**Set montage**](#set-montage) Set the montage information which maps the device channel to the brain region.
- [**Unpack data**](#unpack-data) Read binary data and save CSC (Continuously Sample Channel) signals and timestamps to .mat files.
- [**Automatic spike sort**](#automatic-spike-sorting) Detect spikes and cluster spikes into units.
- [**Extract LFP**](#extract-lfp) Remove spikes in the raw csc signals and downsample to 2k Hz.
- [**Manual spike sort**](#manual-spike-sort) Select spike clusters by visual inspection.
- [**Export to NWB**](#export-to-nwb) Export data to NWB (neural data without borders) format for data sharing.
- [**Read NWB with Python**](#read-nwb-with-python)
- [**Tools**](#Tools) Scripts to do data hotfix.

## How to use:

It is recommended to download the latest release version, which has a smaller size (does not contain the test data), instead of the main branch.

`scripts`: Pipelines to run on the local machine.

`batch`: Pipelines to run on SGE.

### Set montage

Run `MontageConfigUI.m` to open the UI to set the montage:

![image](https://github.com/user-attachments/assets/c1861c5f-edc3-40d1-98b7-25cf529f8c52)



#### Micro channels
- Select `Custom` to input the channel label if it is not in the popup menu.
- To skip a channel, set `Micros` to 0.

#### Macro channels

- Select channels with checkboxes, move them up/down, and remove or add new channels below.
- Use `shift` to select/unselect multiple channels.
- For macro channels, use shift to select multiple cells in the table and delete the contents with `backspace`/`delete`. The empty ports will be automatically filled with the following rules:
    - If `Port Start` is empty, it will be set as `Port End` in the row above + 1.
    - If `Port End` is empty,
        - It will be set as `Port Start` in the row below - 1 if it is not empty
        - Otherwise, it will be set as `Port Start` in the current row.

If there are no skipped ports, you only need to set `Port Start`, `Port End` will be automatically filled. When both `Port Start` and `Port End` are empty at the end of the table, it will be filled assume each channel only takes one port.
      
After setting the montage, clicking `confirm` will save the configuration file (to set up the neuralynx device) and a JSON file, which saves the information in the UI and can be loaded.

### Unpack data

Run in Matlab:
```
scripts/run_unpackNeuralynx
```

You can either define the I/O path in the script or use the UI to select the file path by removing the path definition in the above script:

![image](https://github.com/user-attachments/assets/ad5a6c20-acfc-49a9-afdc-4aca135a00fe)


If you want to rename the channels, set the montage config file (created by `MontageConfigUI.m`) in the script.

```
montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1702_exp-46_2024-06-10_16-52-31.json';
```
Otherwise, set it empty:
```
montageConfigFile = [];
```

### Automatic spike sorting

Define experiment ID and file path in `scripts/run_spikeSorting.m` to run spike sorting:

```
expIds = (4:7);
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';
```

and run in Matlab:
```
scripts/run_spikeSorting
```

This will run spike detection using the minimal threshold across all selected experiments and combine spikes in a single .mat file for each channel.

Or define `expIds` and `job_name` in `batch/runbatch_spikeSorting.m` and run on SGE (hoffman2):

```
qsub batch/runbatch_spikeSorting.sh
```

### Extract LFP

Similar to spike sorting, define `expIds` and `filePath` in `scripts/run_extractLFP.m` and run in matlab:

```
scripts/run_extractLFP
```

Or define `expIds` and `job_name` in `batch/runbatch_extractLFP.m` and run on SGE:

```
qsub batch/runbatch_extractLFP.sh
```

### Manual spike sort

To do manual spike sort, run `wave_clus` in Matlab command window, or open `wave_clus.m` and press the Run button. Press `Load Data` and select the `*_spike.mat` file created by automatic spike sorting.
> You need to run all three steps of automatic spike sorting before the manual spike sort.

![image](https://github.com/user-attachments/assets/a10ae600-e170-4388-a403-2fbb59c1052d)

### Export to NWB

To export data to .nwb file, you need to add [matnwb](https://github.com/NeurodataWithoutBorders/matnwb).

This script will export LFP for all micro and macro channels, spike times, and mean spike waveform (for each unit) to .nwb file:

```
script/run_exportToNwb.m
```

NWB export has a test module for developers:
```
test/test_exportToNwb.m
```

Tutorials for matnwb:

https://neurodatawithoutborders.github.io/matnwb/tutorials/html/intro.html
https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html
https://github.com/NeurodataWithoutBorders/matnwb/blob/master/tutorials/convertTrials.m
https://github.com/rutishauserlab/recogmem-release-NWB/blob/master/RutishauserLabtoNWB/events/newolddelay/matlab/export/NWBexport_demo.m

#### Read NWB with Python

It is recommended that a virtual environment be started for this project. Then install dependencies for Python:

```
pip install -r requirements.txt
```

Start jupyter-notebook in a terminal:

```
jupyter-notebook
```

Open the file `notebooks/demo_readNwb.ipynb` for a demo of reading data from nwb file.

## Structure of repo

### utils

General tools to support the analysis pipeline, including file organization, data manipulation, and configurations.

#### config.m
This script contains the global parameters for the pipeline. 

### ttlUtils
Functions to align TTLs from recording device and experiment PC.

Including name patterns for micro and macro files, files that are ignored when unpacking, etc.

### nwbUtils

functions to write data to NWB files.

### Nlx2Mat

This is the code to read raw neuralynx files. 
https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html

> Note: For Apple Silicon users, run the Intel version of MATLAB using Rosetta.

### NlxIO

classes and functions for Neuralynx IO interface (WIP)

### BlackRockIO

Functions to unpack black rock data.

### montageConfig

UI tools to configure montage settings for neuralynx and BlackRock(wip).

### spikeSort

The code for automatic and manual spike sorting, modified from PDM (by Emily) and Multi-Exp Analysis (by Chris Dao)

#### wave_clus

UI for manual spike sorting, adapted from: [wave_clus](https://github.com/csn-le/wave_clus)

### analysis

functions for screening analysis and raster plots.

### scripts

The scripts to unpack raw data, spike detection, spike clustering, and export data to nwb format.

### batch

The scripts to run the pipeline on Hoffman (SGE).

### notebooks

Jupyter-notebooks to read nwb data in python.

### tools

scripts to do hotfix on data such as rename file names, migrate variables across files, editing variables, and check corrupted .mat files.


### test

This folder contains example data and test modules for developers to debug the code.

### qsub

functions to qsub jobs to SGE (not used so far)

## Troubleshooting

### Eqw on SGE

Use `qstat -j <job_id>` to get detailed information about the job and why it failed.

Once the underlying issue is resolved, you can clear the error state using `qmod -c <job_id>` and then resubmit or restart the job with `qmod -rj <job_id>`.
> You typically do not need to run `qmod -rj` to reschedule a job that has returned to the qw (queued and waiting) status after clearing the Eqw state.

If this is due to memory exceeding the limit. Try to increase `h_data` in the shell script.

### Parallel toolbox not working:
This could be due to pathdef issue, which is caused by multiple versions of Matlab reading/writing to pathdef in ~/Documents/MATLAB. 

See [this post](https://www.mathworks.com/matlabcentral/answers/2113676-matlab-r2023a-parallel-computing-toolbox-is-not-working?s_tid=srchtitle)

First, it is important to take a backup of the current 'pathdef.m' file, which can be located by executing the following command in the MATLAB Command Window:

```
which -all pathdef
```

Ensure that you make a copy of the file by copying it in a location different than its current folder. This is because the steps of this procedure involve regenerating the MATLAB Search Path including resetting the 'pathdef.m' file in its initial state. This procedure will further remove custom paths you may have added in the MATLAB Search Path. 

>Note: If you have multiple files show in the output of this command, remove any files that are not on the $MATLAB/toolbox/local path. MATLAB may encounter issues if it reads multiple pathdef.m files. 

After taking the backup, please execute the following commands in the MATLAB Command Window to restore the default MATLAB Search Path and rehash the toolbox cache:
```
restoredefaultpath
rehash toolboxcache
```

After running these commands, please use MATLAB to see if the initial issue was resolved. Then you may want to save the new MATLAB search path to the 'pathdef.m' file by executing the following command:
```
savepath
```
Note that the above commands will reset any custom paths you have set.


## Matlab toolbox cannot be installed due to permission issue:

See this [solution](https://www.mathworks.com/matlabcentral/answers/334889-can-t-install-any-toolboxes-because-can-t-write-to-usr-local-matlab-r2017)

Run this in Mac terminal:

```
sudo chown -R $LOGNAME: '/Applications/MATLAB_R2023a.app'
```

Or maybe run matlab in terminal:

```
sudo matlab
```

## error in matnwb:
```
object(s) could not be created:
    /processing/ecephys/LFP/ElectricalSeries/electrodes

The listed object(s) above contain an ObjectView, RegionView , or SoftLink object that has failed to resolve itself. Please
check for any references that were not assigned to the root  NwbFile or if any of the above paths are incorrect.
```
Solution:
Add `ElectrodesDynamicTable` to nwb object before adding recordings/processed data.

```
numShanks = 1;
numChannelsPerShank = 4;
 
ElectrodesDynamicTable = types.hdmf_common.DynamicTable(...
    'colnames', {'location', 'group', 'group_name', 'label'}, ...
    'description', 'all electrodes');
 
Device = types.core.Device(...
    'description', 'Neuralynx Pegasus', ...
    'manufacturer', 'Neuralynx' ...
);

shankLabel = {'GA'};
electrodeLabel = {'ROF'};

nwb.general_devices.set('array', Device);
for iShank = 1:numShanks
    shankGroupName = sprintf([shankLabel{iShank}, '%d'], iShank);
    EGroup = types.core.ElectrodeGroup( ...
        'description', sprintf('electrode group for %s', shankGroupName), ...
        'location', 'brain area', ...
        'device', types.untyped.SoftLink(Device) ...
    );
    
    nwb.general_extracellular_ephys.set(shankGroupName, EGroup);
    for iElectrode = 1:numChannelsPerShank
        ElectrodesDynamicTable.addRow( ...
            'location', 'unknown', ...
            'group', types.untyped.ObjectView(EGroup), ...
            'group_name', shankGroupName, ...
            'label', sprintf(['%s-', electrodeLabel{iShank}, '%d'], shankGroupName, iElectrode));
    end
end

nwb.general_extracellular_ephys_electrodes = ElectrodesDynamicTable; % don't forget the last line!!

```
