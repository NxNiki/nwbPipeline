function saveLFPToNwb(nwbFile, expFilePath, samplingRate, electrode_table_region, channel)
% channel: 'LFP_micro' or 'LFP_macro'.


if nargin < 5
    channel = 'LFP_micro';
end

lfpFilePath = fullfile(expFilePath, channel);
lfpFiles = listFiles(lfpFilePath, '*_lfp.mat', '^\.');
lfpTimestampsFile = fullfile(lfpFilePath, 'lfpTimestamps.mat');

lfpTimestampsFileObj = matfile(lfpTimestampsFile);
timestampsStart = lfpTimestampsFileObj.timestampsStart;

lfpLength = 0;

parfor i = 1: length(lfpFiles)
    lfpObj = matfile(lfpFiles{i});
    lfpLength = max(lfpLength, length(lfpObj.lfp));
end

lfpObj = matfile(lfpFiles{1});
lfp = lfpObj.lfp;

if length(lfp) < lfpLength
    warning('lfp length not same across channels, fill short signals with NaNs');
    fprintf('LFP file: %s\n', lfpFiles{1});
    lfp = [lfp(:)', nan(1, lfpLength - length(lfp))];
end

% lfp: sample by channel
lfpSignalCompressed = types.untyped.DataPipe( ...
    'data', lfp(:)', ...
    'chunkSize', [1, lfpLength], ...
    'maxSize', [length(lfpFiles), lfpLength], ...
    'axis', 1);

electrical_series = types.core.ElectricalSeries( ...
    'starting_time', timestampsStart, ... % seconds
    'starting_time_rate', samplingRate, ... % Hz
    'data', lfpSignalCompressed, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts', ...
    'data_conversion', 1e-6);
 
% LFP is for unfiltered local field potential data:
% lfp = types.core.LFP('ElectricalSeries', electrical_series);
lfpEphys = types.core.FilteredEphys('ElectricalSeries', electrical_series);

nwb = nwbRead(nwbFile, 'ignorecache');

if ismember('ecephys', nwb.processing.keys)
    ecephys_module = nwb.processing.get('ecephys');
else
    ecephys_module = types.core.ProcessingModule( ...
        'description', 'extracellular electrophysiology');
end
ecephys_module.nwbdatainterface.set(channel, lfpEphys);

nwb.processing.set('ecephys', ecephys_module);
saveNWB(nwb, nwbFile);

nwb = nwbRead(nwbFile, 'ignorecache'); 
% iteratively adding remaining channels:
for i = 2: length(lfpFiles)
    fprintf('saveLFPToNwb: %s\n', lfpFiles{i});
    lfpObj = matfile(lfpFiles{i});
    lfp = lfpObj.lfp;

    if length(lfp) < lfpLength
        warning('lfp length not same across channels, fill short signals with NaNs');
        warning('LFP file: %s\n', lfpFiles{i});
        lfp = [lfp(:)', nan(1, lfpLength - length(lfp))];
    end
    nwb.processing.get('ecephys').nwbdatainterface.get(channel).electricalseries.get('ElectricalSeries').data.append(lfp);
end


end
