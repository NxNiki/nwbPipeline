# nwbPipeline
Data processing pipeline for iEEG (Neuralynx and Blackrock) recordings.

- **set montage:** Set the montage information which maps the device channel to the brain region.
- **unpack raw data:** Read binary data and save CSC (Continuously Sample Channel) signals and timestamps to .mat files.
- **automatic spike sort:** Detect spikes and cluster spikes into units.
- **extract LFP:** Remove spikes in the raw csc signals and downsample to 2k Hz.
- **convert to NWB:** Export data to NWB (neural data without borders) format for data sharing.
- **manual spike sort:** Select spike clusters by visual inspection.

## How to use:

`scripts`: Pipelines to run on the local machine.

`batch`: Pipelines to run on SGE.

### Set montage:

Run `MontageConfigUI.m` to open the UI to set the montage:

![image](https://github.com/NxNiki/nwbPipeline/assets/4017256/18fa6b1b-3a34-4f07-a18d-1bb9c57869bb)


#### Micro channels:
- Select `Custom` to input the channel label if it is not in the popup menu.
- To skip a channel, set `Micros` to 0.

#### Macro channels:

- Select channels with checkboxes, move them up/down, and remove or add new channels below.
- Use `shift` to select/unselect multiple channels.
- For macro channels, use shift to select multiple cells in the table and delete the contents with `backspace`/`delete`. The empty ports will be automatically filled with the following rules:
    - If `Port Start` is empty, it will be set as `Port End` in the row above + 1.
    - If `Port End` is empty,
        - It will be set as `Port Start` in the row below - 1 if it is not empty
        - Otherwise, it will be set as `Port Start` in the current row.

If there are no skipped ports, you only need to set `Port Start`, `Port End` will be automatically filled. When both `Port Start` and `Port End` are empty at the end of the table, it will be filled assume each channel only takes one port.
      
After setting the montage, clicking `confirm` will save the configuration file (to set up the neuralynx device) and a JSON file, which saves the information in the UI and can be loaded.

### Unpack data:

Run in Matlab:
```
scripts/run_unpackNeuralynx
```

You can either define the I/O path in the script or use the UI to select the file path by removing the path definition in the above script:

![image](https://github.com/NxNiki/nwbPipeline/assets/4017256/d84a562c-816c-4a61-ba5e-4da2062eaabe)

If you want to rename the channels, set the montage config file (created by `MontageConfigUI.m`) in the script.

```
montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1702_exp-46_2024-06-10_16-52-31.json';
```
Otherwise, set it empty:
```
montageConfigFile = [];
```

### Automatic spike sorting:

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

### Extract LFP:

Similar to spike sorting, define `expIds` and `filePath` in `scripts/run_extractLFP.m` and run in matlab:

```
scripts/run_extractLFP
```

Or define `expIds` and `job_name` in `batch/runbatch_extractLFP.m` and run on SGE:

```
qsub batch/runbatch_extractLFP.sh
```

### Export to NWB:

To export data to .nwb file, you need to add [matnwb](https://github.com/NeurodataWithoutBorders/matnwb).
Modify the code in:

```
script/run_exportToNwb.m
```

When you update the code, run the test:

```
test/test_exportToNwb.m
```

### Manual spike sort:

To do manual spike sort, run `wave_clus` in Matlab command window, or open `wave_clus.m` and press the Run button. Press `Load Data` and select the `*_spike.mat` file created by automatic spike sorting.
> You need to run all three steps of automatic spike sorting before the manual spike sort.

![image](https://github.com/user-attachments/assets/a10ae600-e170-4388-a403-2fbb59c1052d)


## config.m

This script contains the global parameters for the pipeline. Including name patterns for micro and macro files, files that are ignored when unpacking, etc.

## Nlx2Mat

This is the code to read raw neuralynx files. 
https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html

Note: this part needs a Matlab version earlier than 2023b on Apple silicon.

## spikeSort

The code for spike sorting, modified from PDM (by Emily) and Multi-Exp Analysis (by Chris Dao)

## scripts

The scripts to unpack raw data, spike detection, spike clustering, and export data to nwb format.

## batch

The scripts to run the pipeline on Hoffman (SGE).

## matnwb:

Code to export data to nwb format. 
https://github.com/NeurodataWithoutBorders/matnwb

## troubleshooting:

### Eqw on SGE:

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
