% plot LFP with raw signals:

clear

% expId = 1;
% expName = '550_Screening';
% channel = 'GA1-ROF2';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/', expName];

% expId = 5;
% expName = '570_MovieParadigm';
% fileName = 'GA1-REC2_lfp.mat';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/', expName];

% expId = 4;
% expName = '570_MovieParadigm';
% fileName = 'GB1-LA8_lfp.mat';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/', expName];

% expId = 2;
% expName = '572_Screening';
% % fileName = 'GA4-RFOpAI1_lfp.mat';
% channel = 'GA3-LAH1';
% filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/', expName];

expId = 1;
expName = '569_Screening';
channel = 'GB1-RA3';
filePath = ['/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/', expName];


%% load data:
expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');
spikesPath = fullfile(expFilePath, 'CSC_micro_spikes');

lfpFileName = [channel, '_lfp.mat'];
spikeFileName = [channel, '_spikes.mat'];

% load data:
lfpFile = fullfile(microLFPPath, lfpFileName);
lfpFileObj = matfile(lfpFile);

spikeFile = fullfile(spikesPath, spikeFileName);
spikeFileObj = matfile(spikeFile);

xfDetect.value = spikeFileObj.xfDetect;
xfDetect.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
xfDetect.label = 'xf_detect';

cscSignal.value = lfpFileObj.cscSignal;
cscSignal.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignal.label = 'cscSignal';

cscSignalSpikesRemoved.value = lfpFileObj.cscSignalSpikesRemoved;
cscSignalSpikesRemoved.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikesRemoved.label = 'cscSignalSpikesRemoved';

interpolateIndex.value = lfpFileObj.interpolateIndex * 50;
interpolateIndex.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
interpolateIndex.label = 'interpolateIndex x 50';

cscSignalSpikeInterpolated.value = lfpFileObj.cscSignalSpikeInterpolated;
cscSignalSpikeInterpolated.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikeInterpolated.label = 'cscSignalSpikeInterpolated';

lfpSignal.value = lfpFileObj.lfp;
lfpSignal.ts = lfpFileObj.lfpTimestamps;
lfpSignal.label = 'lfp';

removedSpikes.value = (lfpFileObj.cscSignal - lfpFileObj.cscSignalSpikesRemoved) * 5;
removedSpikes.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
removedSpikes.label = 'removedSpikes x 5';

removedInterpolateSpikes.value = (lfpFileObj.cscSignal - cscSignalSpikeInterpolated.value) * 5;
removedInterpolateSpikes.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
removedInterpolateSpikes.label = '-cscSignalSpikeInterpolated x 5';

spikeIntervalPercentage = lfpFileObj.spikeIntervalPercentage;

spikeIndex = lfpFileObj.spikeIndex;
% spikeIndex = [];

plotLabel = sprintf([expName, ' Exp %d: ', lfpFileName, ', removed signal: %.3f%%'], expId, spikeIntervalPercentage * 100);

%% plot signal over a large range:

close all

yLimit = [-500, 500] * 1;
xTimeRangeSecs = [0, 100] + 100;

plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)
%plotOverlapSignals(cscSignal, [], cscSignalSpikeInterpolated, xTimeRangeSecs, yLimit, plotLabel)

xTimeRangeSecs = [100, 400];
plotSignalSpectrum(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, plotLabel)

%% select x range:

% close all;

xTimeRangeSecs = [3.65, 3.69];
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, cscSignalSpikeInterpolated, xTimeRangeSecs, [], plotLabel, spikeIndex)

% check why some spikes are opposite:
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, xfDetect, xTimeRangeSecs, [], plotLabel, spikeIndex)

plotOverlapSignals(cscSignal, interpolateIndex, cscSignalSpikeInterpolated, xTimeRangeSecs, [], plotLabel)

plotOverlapSignals(cscSignal, removedSpikes, xfDetect, xTimeRangeSecs, [], plotLabel)

plotOverlapSignals(cscSignal, interpolateIndex, removedInterpolateSpikes, xTimeRangeSecs, [], plotLabel)









