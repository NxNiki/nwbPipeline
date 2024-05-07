% run_extractLFP
clear

expIds = (3:11);
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/573_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0;
saveRaw = 1;

spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% micro electrodes:
microFiles = [];
timestampFiles = [];
for i = 1: length(expIds)
    expId = expIds(i);
    cscFilePath = [filePath, sprintf('/Experiment%d', expId)];
    microFilePath = fullfile(cscFilePath, 'CSC_micro');
    microFiles = [microFiles, readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",")];

    timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
    timestampFiles = [timestampFiles, fullfile(microFilePath, {timestampFiles.name})];
end

spikeFilePath = fullfile(spikeFilePath, 'CSC_micro_spikes');
[~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));



