function [unitsTimeStamp, unitsWaveForm, unitsWaveFormMean, electrodeIndex] = loadSpikes(spikeFiles)
% read units in spike files and concatenate timestamps, waveform, and file
% name in a one dimensional cell array.
% this is used to save spikes into nwb file.


numFiles = length(spikeFiles);
unitsTimeStamp = cell(numFiles, 1);
unitsWaveForm = cell(numFiles, 1);
unitsWaveFormMean = cell(numFiles, 1);
electrodeIndex = cell(numFiles, 1);

for i = 1:numFiles

    spikeFileObj = matfile(spikeFiles{i});
    spikes = spikeFileObj.spikes;
    spikeClass = spikeFileObj.cluster_class(:, 1);
    spikeTimestamps = spikeFileObj.cluster_class(:, 2)';
    
    % remove un-clustered spikes:
    spikes = spikes(spikeClass ~= 0,:);
    spikeClass = spikeClass(spikeClass ~= 0);
    
    units = unique(spikeClass);
    unitsTimeStampi = cell(length(units), 1);
    unitsWaveFormi = cell(length(units), 1);
    unitsWaveFormMeani = cell(length(units), 1);
    unitsLabeli = cell(length(units), 1);
    
    % [~, spikeFileName] = fileparts(spikeFiles{i});
    % unitsLabeli(:) = {regexp(spikeFileName, 'G[A-D]\d-.*', 'match', 'once')};
    unitsLabeli(:) = {i - 1};

    for u = 1:length(units)
        fprintf('load spike: %s, unit %d...\n', spikeFiles{i}, units(u));
    
        unitsTimeStampi{u} = spikeTimestamps(spikeClass==units(u));
        unitsWaveFormi{u} = spikes(spikeClass==units(u), :);
        unitsWaveFormMeani{u} = mean(spikes(spikeClass==units(u), :))';
    end

    unitsTimeStamp{i} = unitsTimeStampi;
    unitsWaveForm{i} = unitsWaveFormi;
    unitsWaveFormMean{i} = unitsWaveFormMeani;
    electrodeIndex{i} = unitsLabeli;

end

unitsTimeStamp = flatten(unitsTimeStamp);
unitsWaveForm = flatten(unitsWaveForm);
electrodeIndex = flatten(electrodeIndex);
unitsWaveFormMean = cell2mat(flatten(unitsWaveFormMean))';


