% test spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expIds = 2;
filePath = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/test/Screening/572_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [0, 0, 0];

[microFiles, timestampFiles, expNames] = readFilePath(expIds, filePath);

%% spike detection:

expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist(1));
disp('Spike Detection Finished!')

%% spike clustering:

spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist(2));

spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist(3));

disp('Spike Clustering finished!')