% run_extractLFP
clear

% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/550_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% micro electrodes:

microFilePath = fullfile(expFilePath, 'CSC_micro');
microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
microFiles = microFiles(2,:);

timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
[~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, true);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));



