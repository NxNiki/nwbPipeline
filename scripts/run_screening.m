% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 573;
expId = 1;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/573_Screening';
filePath = '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/PIPELINE_vc/ANALYSIS/Screening/573_Screening';
expFilePath = [filePath, '/Experiment', sprintf('%d', expId)];
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
imageDirectory = fullfile(expFilePath, '/trial1');

%% parse TTLs:
% this will create TTL.mat and trialStruct.mat

% eventFile = fullfile(expFilePath, 'CSC_events/Events_001.mat');
% ttlLogFile = fullfile(expFilePath, "/from laptop/ttlLog573-02-May-2024-14-54-53.mat");
% trials = parseTTLs_Screening(eventFile, ttlLogFile);
% save(fullfile(expFilePath, 'trialStruct.mat'), 'trials');

%%
load(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
cscFilePath = fullfile(expFilePath, '/CSC_micro');
[clusterCharacteristics] = calculateClusterCharacteristics(spikeFilePath, cscFilePath, trials);
% [clusterCharacteristics] = calculateClusterCharacteristics_video(patient, exp, imageDirectory);

save(fullfile(spikeFilePath, 'clusterCharacteristics.mat'), 'clusterCharacteristics');
%%

% command = ['chmod -R 775 ', filePath];
% system(command)

%%

outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots'];
% rasters_by_unit(patient, spikeFilePath, imageDirectory, 1, 0, outputPath)
rasters_by_unit(patient, spikeFilePath, imageDirectory, 0, 0, outputPath)

rasters_by_image(patient, exp, imageDirectory, 0);

%%

% rasters_by_unit_video(patient, exp, imageDirectory, 1, 0)
rasters_by_unit_video(patient, exp, imageDirectory, 0, 0)
rasters_by_image(patient, exp, imageDirectory, 0);



