function nwb = saveLFPToNwb(nwb, lfpFiles, lfpTimestampsFile, samplingRate, electrode_table_region, Label)


if nargin < 6
    Label = 'LFP';
end

lfpTimestampsFileObj = matfile(lfpTimestampsFile);
timestampsStart = lfpTimestampsFileObj.timestampsStart;

lfpSignals = cell(1, length(lfpFiles));
lfpLength = inf;

for i = 1: length(lfpFiles)
    lfpObj = matfile(lfpFiles{i});
    lfpSignals{i} = lfpObj.lfp;
    lfpLength = min(lfpLength, length(lfpSignals{i}));
end

for i = 1: length(lfpFiles)
    lfp = lfpSignals{i};
    if length(lfp) > lfpLength
        warning('lfp length not same across channels');
        lfpSignals{i} = lfp(1: lfpLength);
    end
end

lfpSignal = vertcat(lfpSignals{:});

electrical_series = types.core.ElectricalSeries( ...
    'starting_time', timestampsStart, ... % seconds
    'starting_time_rate', samplingRate, ... % Hz
    'data', lfpSignal, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'micro-volts');
 
lfp = types.core.LFP('ElectricalSeries', electrical_series);
 

if ismember('ecephys', nwb.processing.keys)
    ecephys_module = nwb.processing.get('ecephys');
else
    ecephys_module = types.core.ProcessingModule('description', 'extracellular electrophysiology');
end

ecephys_module.nwbdatainterface.set(Label, lfp);
nwb.processing.set('ecephys', ecephys_module);

end