% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 1789;
expId = [28 29];
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening';
skipExist = [1, 1, 1];

targetLabel.GA1 = 'Amygdala1'; 
targetLabel.GA2 = 'Thalamus1'; 
targetLabel.GA3 = 'Thalamus2';
targetLabel.GA4 = 'Amygdala2'; 
targetLabel.GB1 = 'Middle hippocampus';
targetLabel.GB2 = 'Posterior hippocampus';
targetLabel.GB3 = 'Putamen1';
targetLabel.GB4 = 'Putamen2';
targetLabel.GC1 = 'Putamen3';
targetLabel.GC3 = 'Putamen4';
targetLabel.GC4 = 'Posterior superior';

% set true to create rasters for reponse (key press):
checkResponseRaster = true;

% In mose case we only have 1 ttlLog file. If the experiment is paused by
% some reason, multiple files are craeted. Make sure log files are ordered
% correctly:
ttlLogFiles = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening/Experiment-28-29/CSC_events/ttlLog.mat';
    };

expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
imageDirectory = fullfile(expFilePath, '/trial1');

%% parse TTLs:
% this will create TTL.mat and trialStruct.mat
% expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];

if ~exist(fullfile(expFilePath, 'TTLs.mat'), "file") || ~skipExist(1)
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

% rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'screeningInfo', targetLabel)
% rasters_by_unit(patient, expFilePath, imageDirectory, 0, 'screeningInfo', targetLabel)
% 
% rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'responseScreeningInfo', targetLabel)
% rasters_by_unit(patient, expFilePath, imageDirectory, 0, 'responseScreeningInfo', targetLabel)
% 
% outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots'];
% rasters_by_image(patient, expFilePath, imageDirectory, 0, outputPath);

outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots_video'];
rasters_by_unit_video(patient, expFilePath, imageDirectory, 1, 0, outputPath, targetLabel)
rasters_by_unit_video(patient, expFilePath, imageDirectory, 0, 0, outputPath, targetLabel)

%%
