% run spike detection and spike sorting to the unpacked data:

% expId = 2;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/550_Screening';

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

outputPath = fullfile(expFilePath, 'CSC_micro_spikes');
spikeFiles = dir(fullfile(outputPath, "spikes_*.mat"));
spikeClustering(spikeFiles, skipExist);






    



