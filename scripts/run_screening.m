% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 577;
expId = 2;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/577_Screening';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/PIPELINE_vc/ANALYSIS/Screening/573_Screening';

expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];

% In mose case we only have 1 ttlLog file. If the experiment is paused by
% some reason, multiple files are craeted. Make sure log files are ordered
% correctly:
ttlLogFiles = {
    '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Screening/D577/Screening 1/577-10-Sep-2024-17-8-26/from laptop/ttlLog577-10-Sep-2024-17-8-26.mat';
    %fullfile(expFilePath, "573-screening Log/573-02-May-2024-15-23-30/from laptop/TTLs573-02-May-2024-15-23-30_room1.mat")
    };

spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
imageDirectory = fullfile(expFilePath, '/trial1');

%% parse TTLs:
% this will create TTL.mat and trialStruct.mat
% expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];
if ~exist(fullfile(expFilePath, 'trialStruct.mat'), "file")
    eventFile = fullfile(expFilePath, 'CSC_events/Events_001.mat');

    TTLs = parseDAQTTLs(eventFile, ttlLogFiles, expFilePath);
    trials = parseTTLs_Screening(TTLs);
    save(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
end

%%

if ~exist(fullfile(spikeFilePath, 'clusterCharacteristics.mat'), "file")
    load(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
    cscFilePath = fullfile(expFilePath, '/CSC_micro');
    [clusterCharacteristics] = calculateClusterCharacteristics(spikeFilePath, cscFilePath, trials, imageDirectory);
    
    save(fullfile(spikeFilePath, 'clusterCharacteristics.mat'), 'clusterCharacteristics');
end

%%

outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots'];
rasters_by_unit(patient, spikeFilePath, imageDirectory, 1, 0, outputPath)
rasters_by_unit(patient, spikeFilePath, imageDirectory, 0, 0, outputPath)
rasters_by_image(patient, spikeFilePath, imageDirectory, 0, outputPath);

%%



