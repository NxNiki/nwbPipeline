function nwb = saveLFPToNwb(nwb, lfpFiles, lfpTimestampsFile, samplingRate, electrode_table_region, Label)


if nargin < 6
    Label = 'LFP';
end

lfpTimestampsFileObj = matfile(lfpTimestampsFile);
timestampsStart = lfpTimestampsFileObj.timestampsStart;

lfpSignals = cell(1, length(lfpFiles));
lfpLength = 0;

for i = 1: length(lfpFiles)
    fprintf('saveLFPToNwb: %s\n', lfpFiles{i});

    lfpObj = matfile(lfpFiles{i});
    lfpSignals{i} = lfpObj.lfp;
    lfpLength = max(lfpLength, length(lfpSignals{i}));
end

for i = 1: length(lfpFiles)
    lfp = lfpSignals{i};
    if length(lfp) > lfpLength
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

if ismember('ecephys', nwb.processing.keys)
    ecephys_module = nwb.processing.get('ecephys');
else
    ecephys_module = types.core.ProcessingModule( ...
        'description', 'extracellular electrophysiology');
end

ecephys_module.nwbdatainterface.set(Label, lfp);
nwb.processing.set('ecephys', ecephys_module);

end
