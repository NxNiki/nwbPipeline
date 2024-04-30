# nwbPipeline
organize iEEG (neuralynx and blackrock) recordings and convert raw data to nwb format.

## config.m

This script contains the global parameters for the pipeline.

## Nlx2Mat

This is the code to read raw neuralynx files. 
https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html

Note: this part needs a Matlab version earlier than 2023b on Apple silicon.

## spikeSort

The code for spike sorting, modified from PDM (by Emily) and Multi-Exp Analysis (by Chris Dao)

## scripts

The scripts to unpack raw data, spike detection, spike clustering, and export data to nwb format.

## matnwb:

Code to export data to nwb format. 
https://github.com/NeurodataWithoutBorders/matnwb

## troubleshooting:

Matlab toolbox cannot be installed due to permission issue:
Run this in Mac terminal:

```
sudo chown -R $LOGNAME: '/Applications/MATLAB_R2023a.app'
```

Or maybe run matlab in terminal:

```
sudo matlab
```


error:
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
