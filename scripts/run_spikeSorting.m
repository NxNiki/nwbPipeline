% run spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expIds = [49:52, 54];
expName = 'MovieParadigm';
patient_id = 1717;

filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s', expName, patient_id, expName);

% 0: overwrite all previous files.
% 1: skip existing files.
skipExist = [1, 0, 0];  % [spike detection, spike code, spike clustering]

% remove noises caused by power line interference:
runRemovePLI = true;

% On Mac studio with 10 cores and 64 GB memory:
% max 4 tasks for movie paradigm (with sleep data)
% max 10 tasks for screening
maxNumCompThreads(4);

batch_spikeSorting(1, 1, expIds, filePath, skipExist, runRemovePLI);
