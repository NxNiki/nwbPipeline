% run_extractLFP
clear

% expId = 4;
% filePath = 'MovieParadigm/570_MovieParadigm';

expId = 2;
filePath = 'Screening/572_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [0, 0]; 
saveRaw = 1;

expFilePath = [filePath, sprintf('/Experiment-%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% micro electrodes:

microFilePath = fullfile(expFilePath, 'CSC_micro');
microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
% microFiles = microFiles(2,:);

timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
[spikeDetectFiles, spikeClusterFiles] = createSpikeFileName(microFiles(:, 1));
spikeClusterFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeClusterFiles, UniformOutput=false);
spikeDetectFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeDetectFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, timestampFiles, spikeDetectFiles, spikeClusterFiles, microLFPPath, '', skipExist(1), saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));


%% macro electrodes:
macroLFPPath = fullfile(expFilePath, 'LFP_macro');
[macroFiles, timestampFiles] = readFilePath(expIds, filePath, 'macro');

% delete(gcp('nocreate')) 
% parpool(3); % each channel will take nearly 20GB memory for multi-exp analysis.

lfpFiles = extractLFP(macroFiles, timestampFiles, '', '', macroLFPPath, '', skipExist(2), saveRaw);
writecell(lfpFiles, fullfile(macroLFPPath, 'lfpFiles.csv'));



