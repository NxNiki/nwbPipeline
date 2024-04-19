% plot LFP with raw signals:

clear
close all

% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
expName = '569_Screening';
fileName = 'GB1-RA2_lfp.mat';
filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/', expName];

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

% load data:
lfpFile = fullfile(microLFPPath, fileName);
lfpFileObj = matfile(lfpFile);

cscSignal.value = lfpFileObj.cscSignal;
cscSignal.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignal.label = 'cscSignal';

cscSignalSpikesRemoved.value = lfpFileObj.cscSignalSpikesRemoved;
cscSignalSpikesRemoved.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikesRemoved.label = 'cscSignalSpikesRemoved';

cscSignalSpikeInterpolated.value = lfpFileObj.cscSignalSpikeInterpolated;
cscSignalSpikeInterpolated.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikeInterpolated.label = 'cscSignalSpikeInterpolated';

lfpSignal.value = lfpFileObj.lfp;
lfpSignal.ts = lfpFileObj.lfpTimestamps;
lfpSignal.label = 'lfp';

removedSpikes.value = (lfpFileObj.cscSignal - lfpFileObj.cscSignalSpikesRemoved) * 20;
removedSpikes.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
removedSpikes.label = 'removedSpikes';

spikeIntervalPercentage = lfpFileObj.spikeIntervalPercentage;

% plot signal over a large range:
yLimit = [-500, 500];
xTimeRangeSecs = [0, inf];

plotLabel = sprintf([expName, ': ', fileName, ', removed signal: %.3f%%'], spikeIntervalPercentage * 100);
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)
plotOverlapSignals(cscSignal, [], cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)

plotSignalSpectrum(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, plotLabel)

%% select x range:

% close all;

xTimeRangeSecs = [441.4, 441.5];
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, [], plotLabel)

% plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, [], interval)
plotOverlapSignals(cscSignal, removedSpikes, [], xTimeRangeSecs, [], plotLabel)









