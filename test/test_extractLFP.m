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

%% micro electrodes:
microFilePath = fullfile(expFilePath, 'CSC_micro');
microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
microLFPPath = fullfile(expFilePath, 'LFP_micro');

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
[macroFiles, timestampFiles] = readFilePath(expId, filePath, 'macro');

lfpFiles = extractLFP(macroFiles, timestampFiles, '', '', macroLFPPath, '', skipExist(2), saveRaw);
writecell(lfpFiles, fullfile(macroLFPPath, 'lfpFiles.csv'));

%% compare micro and micro timestmap files:
microTSObj = matfile(fullfile(microLFPPath, 'lfpTimestamps.mat'));
microTS = microTSObj.lfpTimestamps;

macroTSObj = matfile(fullfile(macroLFPPath, 'lfpTimestamps.mat'));
macroTS = macroTSObj.lfpTimestamps;

startTsDiff = microTSObj.timestampsStart - macroTSObj.timestampsStart
lengthDiff = abs(length(macroTS) - length(microTS))

tsLength = min(length(macroTS), length(microTS));

subplot(3, 1, 1);
plot(microTS(1:tsLength), macroTS(1:tsLength));

subplot(3, 1, 2);
plot(diff(microTS(1:tsLength)), diff(macroTS(1:tsLength)));

subplot(3, 1, 3);
plot(diff(microTS(1:tsLength)) - diff(macroTS(1:tsLength)));
