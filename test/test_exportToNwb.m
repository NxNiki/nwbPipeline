clear

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));
cd(scriptDir)

Device = 'Neuralynx Pegasus';
manufacturer = 'Neuralynx';

expIds = 2;
expName = 'Screening';
patientId = 572;
filePath = 'Screening/572_Screening';

expFilePath = fullfile(filePath, ['/Experiment', sprintf('-%d', expIds)]);
outFilePath = fullfile(expFilePath, 'nwb');
outFile = fullfile(outFilePath, 'ecephys.nwb');

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

%% read timestamp files and init nwb:

date = '1900-01-01'; % Provide default date to protect PHI. Note: This date is not the ACTUAL date of the experiment 
sessionStartTime = datetime(date,'Format','yyyy-MM-dd', 'TimeZone', 'local');

generateCore('2.6.0');

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

Device = types.core.Device(...
    'description', Device, ...
    'manufacturer', 'Neuralynx' ...
);

%% micro and macro LFP:
samplingRate = 2000;

tic
lfpFilePath = fullfile(expFilePath, 'LFP_macro');
lfpFilesMacro = listFiles(lfpFilePath, '*_lfp.mat', '^\._');
lfpTimestampsFile = fullfile(lfpFilePath, 'lfpTimestamps.mat');

[nwb, electrode_table_region] = createElectrodeTable(nwb, lfpFilesMacro, Device);
nwb = saveLFPToNwb(nwb, lfpFilesMacro, lfpTimestampsFile, samplingRate, electrode_table_region, 'macroLFP');
toc

tic
lfpFilePath = fullfile(expFilePath, 'LFP_micro');
lfpFilesMicro = listFiles(lfpFilePath, '*_lfp.mat', '^\.');
lfpTimestampsFile = fullfile(lfpFilePath, 'lfpTimestamps.mat');

[nwb, electrode_table_region] = createElectrodeTable(nwb, lfpFilesMicro, Device);
nwb = saveLFPToNwb(nwb, lfpFilesMicro, lfpTimestampsFile, samplingRate, electrode_table_region, 'microLFP');
toc

%% spikes:

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
spikeFileNames = listFiles(spikeFilePath, '*_spikes.mat', '^\._');
timesFileNames = listFiles(spikeFilePath, 'times*.mat', '^\._');

tic
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
toc

%% 

if exist(outFile, "file")
    % writing to existing .nwb file will cause error when reading it from
    % python.
    delete(outFile);
end
nwbExport(nwb, outFile);

