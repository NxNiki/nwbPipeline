function nwb = saveLFPToNwb(nwb, lfpFilePath, lfpTimestampsFile, samplingRate, electrode_table_region, Label)
lfpFiles = dir(fullfile(lfpFilePath, '*_lfp.mat'));
lfpFiles = fullfile(lfpFilePath, {lfpFiles.name});

lfpTimestampsFileObj = matfile(lfpTimestampsFile);
timestampsStart = lfpTimestampsFileObj.timestampsStart;

lfpSignals = cell(1, length(lfpFiles));
for i = 1: length(lfpFiles)
    lfpObj = matfile(lfpFiles{i});
    lfpSignals{i} = lfpObj.lfp;
end
lfpSignal = vertcat(lfpSignals{:});

electrical_series = types.core.ElectricalSeries( ...
    'starting_time', timestampsStart, ... % seconds
    'starting_time_rate', samplingRate, ... % Hz
    'data', lfpSignal, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts');
 
lfp = types.core.LFP('ElectricalSeries', electrical_series);
 
ecephys_module = types.core.ProcessingModule(...
    'description', 'extracellular electrophysiology');
 
ecephys_module.nwbdatainterface.set(Label, lfp);

nwb.processing.set('ecephys', ecephys_module);
end