% run spike detection and spike sorting to the unpacked data:
clear

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));

expId = 2;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/572_Screening';

% expId = 5;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/570_MovieParadigm';

% expId = 4;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/570_MovieParadigm';


% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%% spike detection:

microFilePath = fullfile(expFilePath, 'CSC_micro');
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
% microFiles = microFiles(2,:);
timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, [], 1);
disp('Spike Detection Finished!')

%% spike clustering:

spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist);

spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist);
disp('Spike Clustering finished!')







    



