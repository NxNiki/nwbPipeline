% run spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expIds = [4];
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/FaceRecognition/486_FaceRecognition';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [1, 1, 0];
runRemovePLI = true;

[microFiles, timestampFiles, expNames] = readFilePath(expIds, filePath);

%% spike detection:
delete(gcp('nocreate'))
% parpool(1); % each channel will take nearly 30GB memory for multi-exp analysis.

expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist(1), runRemovePLI);
disp('Spike Detection Finished!')

%% spike clustering:

spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist(2));

spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist(3));

disp('Spike Clustering finished!')







    



