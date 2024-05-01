% run_extractLFP
clear

% expId = 4;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/569_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 
saveRaw = 1;

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% micro electrodes:

microFilePath = fullfile(expFilePath, 'CSC_micro');
microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
% microFiles = microFiles(2,:);

timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
[~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));



