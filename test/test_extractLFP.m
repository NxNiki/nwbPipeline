clear
close

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

expFilePath = [scriptDir, '/neuralynx'];

lfpFs = 2000;  %Hz
% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = [0, 0]; 
saveRaw = 0;

microFilePath = fullfile(expFilePath, 'CSC_micro');
macroFilePath = fullfile(expFilePath, 'CSC_macro');
%% save down sampled timestamps for micro and macro channels:
microLFPPath = fullfile(expFilePath, 'LFP_micro');
macroLFPPath = fullfile(expFilePath, 'LFP_macro');

timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
microTimestampFiles = fullfile(microFilePath, {timestampFiles.name});

timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
macroTimestampFiles = fullfile(microFilePath, {timestampFiles.name});

lfpTimestamps = downsampleTimestamps(microTimestampFiles, macroTimestampFiles, lfpFs, expFilePath);
%% micro electrodes:

microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
[spikeDetectFiles, spikeClusterFiles] = createSpikeFileName(microFiles(:, 1));
spikeClusterFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeClusterFiles, UniformOutput=false);
spikeDetectFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeDetectFiles, UniformOutput=false);

lfpFiles = extractLFP(microFiles, microTimestampFiles, lfpTimestamps, spikeDetectFiles, spikeClusterFiles, microLFPPath, skipExist(1), saveRaw);
writecell(lfpFiles, fullfile(microLFPPath, 'lfpFiles.csv'));

%% macro electrodes:

macroFiles = readcell(fullfile(macroFilePath, 'outFileNames.csv'), Delimiter=",");

lfpFiles = extractLFP(macroFiles, macroTimestampFiles, lfpTimestamps, '', '', macroLFPPath, skipExist(2), saveRaw);
writecell(lfpFiles, fullfile(macroLFPPath, 'lfpFiles.csv'));

