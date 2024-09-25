% test spike clustering:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

filePath = [scriptDir, '/neuralynx'];

spikeFiles = {
    [filePath, '/spike_files/GA1-LOF1_spikes.mat']
    };
spikeCodeFiles = {
    [filePath, '/spike_files/GA1-LOF1_spikeCodes.mat']
    };

outputPath = fullfile(filePath, 'spike_files');

%% spike clustering:

spikeClustering(spikeFiles, spikeCodeFiles, outputPath, 0);

disp('Spike Clustering finished!')
