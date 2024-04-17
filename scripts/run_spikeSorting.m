% run spike detection and spike sorting to the unpacked data:
clear

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));

% expId = 2;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/555_Screening';

% expId = 5;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/569_Screening';


% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%% spike detection:

microFilePath = fullfile(expFilePath, 'CSC_micro');
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

spikeDetection(microFiles, timestampFiles, outputPath, [], skipExist)

%% spike clustering:

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeFiles = dir(fullfile(spikeFilePath, "*_spikes.mat"));
spikeFiles = cellfun(@(f, n)fullfile(f, n), {spikeFiles.folder}, {spikeFiles.name}, UniformOutput=false);

spikeClustering(spikeFiles, outputPath, skipExist);







    



