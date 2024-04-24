% plot LFP with raw signals:

clear

% expId = 5;
% expName = '570_MovieParadigm';
% fileName = 'GA1-REC2_lfp.mat';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/', expName];

expId = 2;
expName = '572_Screening';
fileName = 'GA4-RFOpAI1_lfp.mat';
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
removedSpikes.label = 'removedSpikes x 20';

removedInterpolateSpikes.value = (lfpFileObj.cscSignal - cscSignalSpikeInterpolated.value) * 20;
removedInterpolateSpikes.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
removedInterpolateSpikes.label = '-cscSignalSpikeInterpolated x 20';

spikeIntervalPercentage = lfpFileObj.spikeIntervalPercentage;

%% plot signal over a large range:

close all

yLimit = [-500, 500] * 2;
xTimeRangeSecs = [0, 100] + 100;

plotLabel = sprintf([expName, ': ', fileName, ', removed signal: %.3f%%'], spikeIntervalPercentage * 100);
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)
%plotOverlapSignals(cscSignal, [], cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)

xTimeRangeSecs = [0, inf];
plotSignalSpectrum(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, plotLabel)

%% select x range:

% close all;

xTimeRangeSecs = [52.38, 52.4];
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, [], plotLabel)

plotOverlapSignals(cscSignal, removedSpikes, [], xTimeRangeSecs, [], plotLabel)

plotOverlapSignals(cscSignal, [], removedInterpolateSpikes, xTimeRangeSecs, [], plotLabel)







