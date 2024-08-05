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

lfpSignals = cell(1, length(lfpFiles));
lfpLength = 0;

parfor i = 1: length(lfpFiles)
    fprintf('saveLFPToNwb: %s\n', lfpFiles{i});

    lfpObj = matfile(lfpFiles{i});
    lfpSignals{i} = lfpObj.lfp;
    lfpLength = max(lfpLength, length(lfpSignals{i}));
end

for i = 1: length(lfpFiles)
    lfp = lfpSignals{i};
    if length(lfp) < lfpLength
        warning('lfp length not same across channels, fill short signals with NaNs');
        fprintf('LFP file: %s\n', lfpFiles{i});
        lfpSignals{i} = [lfp(:)', nan(1, lfpLength - length(lfp))];
    else
        lfpSignals{i} = lfp(:)';
    end
end

lfpSignal = vertcat(lfpSignals{:});

electrical_series = types.core.ElectricalSeries( ...
    'starting_time', timestampsStart, ... % seconds
    'starting_time_rate', samplingRate, ... % Hz
    'data', lfpSignal, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts', ...
    'data_conversion', 1e-6);
 
% LFP is for unfiltered local field potential data:
% lfp = types.core.LFP('ElectricalSeries', electrical_series);

lfp = types.core.FilteredEphys('ElectricalSeries', electrical_series);

nwb = nwbRead(nwbFile);
if ismember('ecephys', nwb.processing.keys)
    ecephys_module = nwb.processing.get('ecephys');
else
    ecephys_module = types.core.ProcessingModule( ...
        'description', 'extracellular electrophysiology');
end
ecephys_module.nwbdatainterface.set(channel, lfp);

nwb.processing.set('ecephys', ecephys_module);
saveNWB(nwb, nwbFile)

end
