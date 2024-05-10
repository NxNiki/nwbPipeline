% run_extractLFP
clear

expIds = (3:11);
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/573_MovieParadigm';

filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1;
saveRaw = false;

spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
microLFPPath = fullfile(spikeFilePath, 'LFP_micro');

%% micro electrodes:
microFiles = [];
timestampFiles = [];
for i = 1: length(expIds)
    expId = expIds(i);
    cscFilePath = [filePath, sprintf('/Experiment%d', expId)];
    microFilePath = fullfile(cscFilePath, 'CSC_micro');
    microFiles = [microFiles, readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",")];

    timestampFilesExp = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
    timestampFiles = [timestampFiles, fullfile(microFilePath, {timestampFilesExp.name})];
end

% delete(gcp('nocreate')) 
% parpool(3); % each channel will take nearly 20GB memory for multi-exp analysis.

spikeFilePath = fullfile(spikeFilePath, 'CSC_micro_spikes');
[~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));



