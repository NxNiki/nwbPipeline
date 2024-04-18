% run_extractLFP
clear
close all
% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/569_Screening';

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% plot LFP with raw signals:


lfpFile = fullfile(microLFPPath, 'GB1-RA2_lfp.mat');
lfpFileObj = matfile(lfpFile);

cscSignal.value = lfpFileObj.cscSignal;
cscSignal.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignal.label = 'cscSignal';

cscSignalSpikesRemoved.value = lfpFileObj.cscSignalSpikesRemoved;
cscSignalSpikesRemoved.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikesRemoved.label = 'cscSignalSpikesRemoved';

lfpSignal.value = lfpFileObj.lfp;
lfpSignal.ts = lfpFileObj.lfpTimestamps;
lfpSignal.label = 'lfp';

removedSpikes.value = (lfpFileObj.cscSignal - lfpFileObj.cscSignalSpikesRemoved) * 20;
removedSpikes.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
removedSpikes.label = 'removedSpikes';

%%

plotOverlapSignals(cscSignal, [], lfpSignal, [20, 50])

%%

interval = [30.48, 30.58];
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, lfpSignal, interval)

plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, [], interval)

plotOverlapSignals(cscSignal, removedSpikes, [], interval)









