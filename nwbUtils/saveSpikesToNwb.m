function saveSpikesToNwb(nwbFile, expFilePath)

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
spikeFileNames = listFiles(spikeFilePath, '*_spikes.mat', '^\._');
timesFileNames = listFiles(spikeFilePath, 'times*.mat', '^\._');

% load spikes for all channels:
[spikeTimestamps, spikeWaveForm, spikeWaveFormMean, spikeElectrodesIdx] = loadSpikes(spikeFileNames, timesFileNames);

if isempty(spikeTimestamps)
    warning('no spikes detected in: %s\n', spikeFileNames);
end

[spike_times_vector, spike_times_index] = util.create_indexed_column(spikeTimestamps);
[electrodes, electrodes_index] = util.create_indexed_column(spikeElectrodesIdx, [], '/general/extracellular_ephys/electrodes' );

nwb = nwbRead(nwbFile, 'ignorecache');
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

% export nwb to save memory usage:
saveNWB(nwb, nwbFile, 1);
