% run spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expIds = [2];
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/576_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [1, 1, 0];

% remove noises caused by power line interference:
runRemovePLI = false;

maxNumCompThreads(10);

batch_spikeSorting(1, 1, expIds, filePath, skipExist, runRemovePLI);
