% run_extractLFP
clear
close all;

% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/550_Screening';

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];
microLFPPath = fullfile(expFilePath, 'LFP_micro');

%% plot LFP with raw signals:


lfpFile = fullfile(microLFPPath, 'GA1-ROF2_lfp.mat');
lfpFileObj = matfile(lfpFile);

cscSignal.value = lfpFileObj.cscSignal;
cscSignal.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignal.label = 'cscSignal';

cscSignalSpikesRemoved.value = lfpFileObj.cscSignalSpikesRemoved * 20;
cscSignalSpikesRemoved.ts = lfpFileObj.rawTimestamps - lfpFileObj.rawTimestamps(1, 1);
cscSignalSpikesRemoved.label = 'cscSignalSpikesRemoved';

lfpSignal.value = lfpFileObj.lfp;
lfpSignal.ts = lfpFileObj.lfpTimestamps;
lfpSignal.label = 'lfp';

%%
plotOverlapSignals(cscSignal, [], lfpSignal, [0, 100])

%%
plotOverlapSignals(cscSignal, cscSignalSpikesRemoved, lfpSignal, [99, 100])







