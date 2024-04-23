% plot LFP with raw signals:

clear
close all

% expId = 5;
% expName = '570_MovieParadigm';
% fileName = 'GA1-REC2_lfp.mat';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/', expName];

expId = 2;
expName = '572_Screening';
fileName = 'GB1-RA2_lfp.mat';
filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/', expName];

%% load data:
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

%% plot signal over a large range:

yLimit = [-1000, 1000];
xTimeRangeSecs = [0, 100] + 600;

plotLabel = sprintf([expName, ': ', fileName, ', removed signal: %.3f%%'], spikeIntervalPercentage * 100);
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)
%plotOverlapSignals(cscSignal, [], cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)

plotSignalSpectrum(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, plotLabel)

%% select x range:

% close all;

xTimeRangeSecs = [52.31, 52.55];
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, [], plotLabel)

plotOverlapSignals(cscSignal, removedSpikes, [], xTimeRangeSecs, [], plotLabel)









