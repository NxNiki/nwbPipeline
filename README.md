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

Parallel toolbox not working:
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


Matlab toolbox cannot be installed due to permission issue:

See this [solution](https://www.mathworks.com/matlabcentral/answers/334889-can-t-install-any-toolboxes-because-can-t-write-to-usr-local-matlab-r2017)

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
