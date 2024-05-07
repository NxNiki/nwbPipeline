% run spike detection and spike sorting to the unpacked data:
clear

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));

expIds = (3: 11);
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';


% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1;

microFiles = [];
timestampFiles = [];
expNamesId = 1;

for i = 1:length(expIds)
    expFilePath = [filePath, '/Experiment', sprintf('%d/', expIds(i))];
    microFilePath = fullfile(expFilePath, 'CSC_micro');
    microFiles = [microFiles, readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",")];
    timestampFile = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
    timestampFiles = [timestampFiles, fullfile(microFilePath, {timestampFile.name})];
    expNames(expNamesId: length(timestampFiles)) = {sprintf('Exp%d', expIds(i))};
    expNamesId = length(timestampFiles) + 1;
end


%% spike detection:
delete(gcp('nocreate'))
parpool(2);

expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];

outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist)
disp('Spike Detection Finished!')

%% spike clustering:

spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

spikeFiles = dir(fullfile(spikeFilePath, "*_spikes.mat"));
spikeFiles = cellfun(@(f, n)fullfile(f, n), {spikeFiles.folder}, {spikeFiles.name}, UniformOutput=false);

spikeClustering(spikeFiles, outputPath, skipExist);
disp('Spike Clustering finished!')







    



