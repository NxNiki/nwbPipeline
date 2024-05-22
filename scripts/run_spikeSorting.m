% run spike detection and spike sorting to the unpacked data:
clear

% addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));
addpath(genpath('/u/home/x/xinniu/nwbPipeline'));

expIds = (4:7);
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';
filePath = '/u/project/ifried/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';


% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1;

[microFiles, timestampFiles, expNames] = readFilePath(expIds, filePath);

%% spike detection:
delete(gcp('nocreate'))
parpool(1); % each channel will take nearly 30GB memory for multi-exp analysis.

expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist);
disp('Spike Detection Finished!')

%% spike clustering:

spikeClustering(spikeFiles, outputPath, skipExist);
disp('Spike Clustering finished!')







    



