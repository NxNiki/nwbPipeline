% run spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expIds = [48:51];
expName = 'MovieParadigm';
patient_id = 1741;


filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s', expName, patient_id, expName);


% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [1, 1, 0]; % [spike detection, spike code, spike clustering]

% remove noises caused by power line interference:
runRemovePLI = true;

maxNumCompThreads(4);

batch_spikeSorting(1, 1, expIds, filePath, skipExist, runRemovePLI);
