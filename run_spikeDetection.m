% run spike detection and spike sorting to the unpacked data:

expId = 2;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

expId = 5;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%%

microFilePath = fullfile(expFilePath, 'CSC_micro');
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

microFiles = microFiles(1:2,:);

spikeDetection(microFiles, timestampFiles, outputPath, skipExist)

    



