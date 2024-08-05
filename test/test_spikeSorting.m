% test spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

filePath = [scriptDir, '/neuralynx'];

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [0, 0, 0];

microFiles = {
    [filePath, '/CSC_micro/GA1-RA1_001.mat']
    [filePath, '/CSC_micro/GB2-RAH1_001.mat']
    [filePath, '/CSC_micro/GD4-LEC1_001.mat']
    };
timestampFiles = {
    [filePath, '/CSC_micro/lfpTimeStamps_001.mat']
    };
%% spike detection:

outputPath = fullfile(filePath, 'CSC_micro_spikes');

spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, [], skipExist(1));
disp('Spike Detection Finished!')

%% spike clustering:

spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist(2));

spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist(3));

disp('Spike Clustering finished!')