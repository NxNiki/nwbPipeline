% run spike detection and spike sorting to the unpacked data:

% expId = 2;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

expId = 5;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%%

macroFilePath = fullfile(expFilePath, 'CSC_macro');

macroFiles = readcell(fullfile(macroFilePath, 'outFileNames.csv'));
timestampFiles = dir(fullfile(macroFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(macroFilePath, {timestampFiles.name});

for i = 1: size(macroFiles, 1)
    [signal, timestamps, samplingInterval] = combineCSC(macroFiles(i,:));

    



