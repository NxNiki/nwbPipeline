% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 573;
expId = 1;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/573_Screening';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/PIPELINE_vc/ANALYSIS/Screening/573_Screening';

% make sure log files are ordered correctly:
ttlLogFiles = {
    fullfile(expFilePath, "573-screening Log/573-02-May-2024-14-54-53/from laptop/ttlLog573-02-May-2024-14-54-53.mat");
    fullfile(expFilePath, "573-screening Log/573-02-May-2024-15-23-30/from laptop/TTLs573-02-May-2024-15-23-30_room1.mat")
    };

expFilePath = [filePath, '/Experiment', sprintf('%d', expId)];
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
imageDirectory = fullfile(expFilePath, '/trial1');

%% parse TTLs:
% this will create TTL.mat and trialStruct.mat

if ~exist(fullfile(expFilePath, 'trialStruct.mat'), "file")
    eventFile = fullfile(expFilePath, 'CSC_events/Events_001.mat');

    TTLs = parseDAQTTLs(eventFile, ttlLogFiles, expFilePath);
    trials = parseTTLs_Screening(TTLs);
    save(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
end

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

% TO DO save plots for video separately.
outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots'];
rasters_by_unit(patient, spikeFilePath, imageDirectory, 1, 0, outputPath)
rasters_by_unit(patient, spikeFilePath, imageDirectory, 0, 0, outputPath)
rasters_by_image(patient, spikeFilePath, imageDirectory, 0, outputPath);

%%



