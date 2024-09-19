% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 576;
expId = [23];
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/576_Screening';
skipExist = [1, 1, 1];

% set true to create rasters for reponse (key press):
checkResponseRaster = true;

% In mose case we only have 1 ttlLog file. If the experiment is paused by
% some reason, multiple files are craeted. Make sure log files are ordered
% correctly:
ttlLogFiles = {
    '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Screening/D576/Screening4/576-18-Sep-2024-17-35-19/from laptop/ttlLog576-18-Sep-2024-17-35-19.mat';
    };

expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
imageDirectory = fullfile(expFilePath, '/trial1');

%% parse TTLs:
% this will create TTL.mat and trialStruct.mat
% expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];

if ~exist(fullfile(expFilePath, 'trialStruct.mat'), "file") || ~skipExist(1)
    eventFile = fullfile(expFilePath, 'CSC_events/Events_001.mat');

    TTLs = parseDAQTTLs(eventFile, ttlLogFiles, expFilePath);
    disp('save TTL');
    save(fullfile(expFilePath, 'TTLs.mat'), 'TTLs');
end

if ~exist(fullfile(expFilePath, 'trialStruct.mat'), "file") || ~skipExist(2)
    load(fullfile(expFilePath, 'TTLs.mat'), 'TTLs');
    trials = parseTTLs_Screening(TTLs);
    disp('save trialStruct');
    save(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
end

%%

if ~exist(fullfile(expFilePath, 'clusterCharacteristics.mat'), "file") || ~skipExist(3)
    load(fullfile(expFilePath, 'trialStruct.mat'), 'trials');
    cscFilePath = fullfile(expFilePath, '/CSC_micro');
    disp('save clusterCharacteristics...');
    tic
    [clusterCharacteristics, samplingRate] = calculateClusterCharacteristics(spikeFilePath, cscFilePath, trials, imageDirectory, checkResponseRaster);
    save(fullfile(expFilePath, 'clusterCharacteristics.mat'), 'clusterCharacteristics', 'samplingRate');
    toc
end

%%

% rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'screeningInfo')
% rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'responseScreeningInfo')
rasters_by_unit(patient, expFilePath, imageDirectory, 0, 'responseScreeningInfo')

% rasters_by_image(patient, expFilePath, imageDirectory, 0, outputPath);

% outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots_video'];
% rasters_by_unit_video(patient, expFilePath, imageDirectory, 1, 0, outputPath)
% rasters_by_unit_video(patient, expFilePath, imageDirectory, 0, 0, outputPath)

%%
