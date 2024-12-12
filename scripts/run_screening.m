% before run_screening.m, make sure data is unpacked and spike sorted.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

patient = 579;
expId = [2];
filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/%d_Screening', patient);
skipExist = [1, 1, 1];

% set target local for each micro channel:
targetLabel.GA1 = ''; 
targetLabel.GA2 = ''; 
targetLabel.GA3 = '';
targetLabel.GA4 = ''; 
targetLabel.GB1 = '';
targetLabel.GB2 = '';
targetLabel.GB3 = '';
targetLabel.GB4 = '';
targetLabel.GC1 = '';
targetLabel.GC2 = '';
targetLabel.GC3 = '';
targetLabel.GC4 = '';

% set true to create rasters for reponse (key press):
checkResponseRaster = true;

% In mose case we only have 1 ttlLog file. If the experiment is paused by
% some reason, multiple files are craeted. Make sure log files are ordered
% correctly:
ttlLogFiles = {
    '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Screening/D579/Screening 1 _Behavioural/579-10-Dec-2024-20-35-41/from laptop/ttlLog579-10-Dec-2024-20-35-41.mat';
    };

imageDirectory = '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/Screening/D579/Screening 1 Stimuli';

expFilePath = [filePath, '/Experiment', sprintf('-%d', expId)];
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];
% imageDirectory = fullfile(expFilePath, '/trial1');

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

rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'screeningInfo', targetLabel)
rasters_by_unit(patient, expFilePath, imageDirectory, 0, 'screeningInfo', targetLabel)

rasters_by_unit(patient, expFilePath, imageDirectory, 1, 'responseScreeningInfo', targetLabel)
rasters_by_unit(patient, expFilePath, imageDirectory, 0, 'responseScreeningInfo', targetLabel)

outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots'];
rasters_by_image(patient, expFilePath, imageDirectory, 0, outputPath);

outputPath = [filePath, '/Experiment', sprintf('-%d', expId), '/raster_plots_video'];
rasters_by_unit_video(patient, expFilePath, imageDirectory, 1, 0, outputPath, targetLabel)
rasters_by_unit_video(patient, expFilePath, imageDirectory, 0, 0, outputPath, targetLabel)

%%
