% export csc, spikes, lfp, etc to .nwb file.

% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/intro.html#H_FF8B1A2D
% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html
% https://github.com/NeurodataWithoutBorders/matnwb/blob/master/tutorials/convertTrials.m
% https://github.com/rutishauserlab/recogmem-release-NWB/blob/master/RutishauserLabtoNWB/events/newolddelay/matlab/export/NWBexport_demo.m

clear

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

Device = 'Neuralynx Pegasus';
manufacturer = 'Neuralynx';

expIds = 2;
expName = 'Screening';
patientId = 572;
filePath = 'Screening/572_Screening';

outFilePath = [filePath, sprintf('/Experiment-%d/nwb', expIds)];

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

expFilePath = fullfile(filePath, sprintf('/Experiment-%d/', expIds));
%% read timestamp files and init nwb:

% timestampFiles = dir(fullfile(microFilePath, '/CSC_micro/lfpTimeStamps*.mat'));
% timestampFiles = fullfile(microFilePath, {timestampFiles.name});
% tsObj = matfile(timestampFiles{1});
% sessionStartTime = datetime(tsObj.timeStamps(1,1), 'convertfrom','posixtime', 'Format','dd-MMM-yyyy HH:mm:ss.SSS');

date = '1900-01-01'; % Provide default date to protect PHI. Note: This date is not the ACTUAL date of the experiment 
sessionStartTime = datetime(date,'Format','yyyy-MM-dd', 'TimeZone', 'local');

% generateCore('2.6.0');

nwb = NwbFile( ...
    'session_description', ['sub-' num2str(patientId), '_exp', sprintf('-%d', expIds), '_' expName],...
    'identifier', ['sub-' num2str(patientId), '_exp', sprintf('-%d', expIds), '_' expName], ...
    'session_start_time', sessionStartTime, ...
    'timestamps_reference_time', sessionStartTime, ...
    'general_experimenter', 'My Name', ... % optional
    'general_session_id', '', ... % optional
    'general_institution', 'UCLA', ... % optional
    'general_related_publications', ''); % optional

subject = types.core.Subject( ...
    'subject_id', num2str(patientId), ...
    'age', '', ...
    'description', '', ...
    'species', 'human', ...
    'sex', 'M' ...
);
nwb.general_subject = subject;

%% Electrodes Table:


ElectrodesDynamicTable = types.hdmf_common.DynamicTable(...
    'colnames', {'x', 'y', 'z', 'location', 'group', 'group_name', 'label'}, ...
    'description', 'all electrodes');
 
Device = types.core.Device(...
    'description', Device, ...
    'manufacturer', manufacturer ...
);

shankLabel = {'GA1', 'GA2', 'GA3'};
electrodeLabel = {'RA1', 'REC1', 'RAH1'};
numShanks = length(shankLabel);
numChannelsPerShank = 1;

nwb.general_devices.set('array', Device);
for iShank = 1:numShanks
    shankGroupName = shankLabel{iShank};
    EGroup = types.core.ElectrodeGroup( ...
        'description', sprintf('electrode group for %s', shankGroupName), ...
        'location', electrodeLabel{iShank}, ...
        'device', types.untyped.SoftLink(Device) ...
    );
    
    nwb.general_extracellular_ephys.set(shankGroupName, EGroup);
    for iElectrode = 1:numChannelsPerShank
        location = sprintf(['%s-', electrodeLabel{iShank}, '%d'], shankGroupName, iElectrode);
        ElectrodesDynamicTable.addRow( ...
            'x', 111, ...
            'y', 111, ...
            'z', 111, ...
            'location', location, ...
            'group', types.untyped.ObjectView(EGroup), ...
            'group_name', shankGroupName, ...
            'label', location);
    end
end

ElectrodesDynamicTable.toTable()
nwb.general_extracellular_ephys_electrodes = ElectrodesDynamicTable;

electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
    'table', types.untyped.ObjectView(ElectrodesDynamicTable), ...
    'description', 'all electrodes', ...
    'data', (0:length(ElectrodesDynamicTable.id.data)-1)');


%%  Electrical Series:
% we don't save raw signals to save storage space:

% microFilePath = fullfile(filePath, sprintf('/Experiment%d/CSC_micro', expId));
% microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
% 
% voltageSignals = cell(1, length(microFiles));
% for i = 1: length(microFiles)
%     [voltageSignals{i}, ~, samplingInterval] = combineCSC(microFiles(i,:), timestampFiles);
% end
% voltageSignal = vertcat(voltageSignals{:});
% 
% electrical_series = types.core.ElectricalSeries( ...
%     'starting_time', 0.0, ... % seconds
%     'starting_time_rate', 1/seconds(samplingInterval), ... % Hz
%     'data', voltageSignal, ...
%     'electrodes', electrode_table_region, ...
%     'data_unit', 'volts');
% 
% nwb.acquisition.set('ElectricalSeries', electrical_series);

%% LFP:
samplingRate = 2000;

lfpFilePath = fullfile(filePath, sprintf('/Experiment-%d/LFP_micro', expIds));
lfpFiles = dir(fullfile(lfpFilePath, '*_lfp.mat'));
lfpFilesMicro = fullfile(lfpFilePath, {lfpFiles.name});
lfpTimestampsFile = fullfile(filePath, sprintf('/Experiment-%d/LFP_micro/lfpTimestamps.mat', expIds));
nwb = saveLFPToNwb(nwb, lfpFilesMicro, lfpTimestampsFile, samplingRate, electrode_table_region, 'microLFP');

lfpFilePath = fullfile(filePath, sprintf('/Experiment-%d/LFP_macro', expIds));
lfpTimestampsFile = fullfile(filePath, sprintf('/Experiment-%d/LFP_macro/lfpTimestamps.mat', expIds));
% nwb = saveLFPToNwb(nwb, lfpFilePath, lfpTimestampsFile, samplingRate, electrode_table_region, 'macroLFP');

%% spikes:

spikeFilePath = fullfile(filePath, sprintf('/Experiment-%d/CSC_micro_spikes', expIds));
spikeFileNames = dir(fullfile(spikeFilePath, '*_spikes.mat'));
spikeFileNames = fullfile(spikeFilePath, {spikeFileNames.name});

timesFileNames = dir(fullfile(spikeFilePath, 'times*.mat'));
timesFileNames = fullfile(spikeFilePath, {timesFileNames.name});

% load spikes for all channels:
[spikeTimestamps, spikeWaveForm, spikeWaveFormMean, spikeElectrodesIdx] = loadSpikes(spikeFileNames, timesFileNames);

[spike_times_vector, spike_times_index] = util.create_indexed_column(spikeTimestamps);
[electrodes, electrodes_index] = util.create_indexed_column(spikeElectrodesIdx, [], '/general/extracellular_ephys/electrodes' );
 
nwb.units = types.core.Units( ...
    'colnames', {'spike_times', 'electrodes', 'waveform_mean'}, ... 
    'description', 'units table', ...
    'id', types.hdmf_common.ElementIdentifiers('data', int64(0:length(spikeTimestamps) - 1)), ...
    'spike_times', spike_times_vector, ...
    'spike_times_index', spike_times_index, ...
    'electrodes', electrodes, ...
    'electrodes_index', electrodes_index, ...
    'waveform_mean', types.hdmf_common.VectorData('data', spikeWaveFormMean', 'description', 'Mean Spike Waveforms') ...
);

% save wave forms:
% nwb.units.vectordata.set('waveform_mean', types.hdmf_common.VectorData('data', spikeWaveFormMean', 'description', 'Mean Spike Waveforms'));


%% 

nwbExport(nwb, fullfile(outFilePath, 'ecephys_572.nwb'));

