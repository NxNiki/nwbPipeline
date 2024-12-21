% run spike detection and spike sorting to the unpacked data:
clear

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

% expName = 'MovieParadigm';
expName = 'ABCD';

patient_id = 579;
expIds = [3];

% On Mac studio with 10 cores and 64 GB memory:
% max 4 tasks for movie paradigm (with sleep data)
% max 10 tasks for screening
numParallelJobs = 8;


% filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s_xin', expName, patient_id, expName);
filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s', expName, patient_id, expName);

% 0: overwrite all previous files.
% 1: skip existing files.
skipExist = [1, 0, 0];  % [spike detection, spike code, spike clustering]

% remove median across channels in each bundle:
runCAR = true;

% remove noises caused by power line interference:
runRemovePLI = false;

% calculate spikeCodes and reject noise spikes:
runRejectSpike = false;


maxNumCompThreads(numParallelJobs);
batch_spikeSorting(1, 1, expIds, filePath, skipExist, runRemovePLI, runCAR, runRejectSpike);
