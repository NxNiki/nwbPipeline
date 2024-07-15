% run_extractLFP
clear

expIds = (3:11);
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [1, 0];
saveRaw = false;

expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
%% micro electrodes:
microLFPPath = fullfile(expFilePath, 'LFP_micro');
[microFiles, timestampFiles] = readFilePath(expIds, filePath);

% delete(gcp('nocreate')) 
% parpool(3); % each channel will take nearly 20GB memory for multi-exp analysis.

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
[~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, '', microLFPPath, '', skipExist(1), saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));

%% macro electrodes:
macroLFPPath = fullfile(expFilePath, 'LFP_macro');
[macroFiles, timestampFiles] = readFilePath(expIds, filePath, 'macro');

% delete(gcp('nocreate')) 
% parpool(3); % each channel will take nearly 20GB memory for multi-exp analysis.

lfpFiles = extractLFP(macroFiles, timestampFiles, '', '', macroLFPPath, '', skipExist(2), saveRaw);
writecell(lfpFiles, fullfile(macroLFPPath, 'lfpFiles.csv'));

