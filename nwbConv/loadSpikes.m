function [unitsTimeStamp, unitsWaveForm, unitsWaveFormMean, electrodeIndex] = loadSpikes(spikesFiles, timesFiles)
% read units in spike files and concatenate timestamps, waveform, and file
% name in a one dimensional cell array.
% this is used to save spikes into nwb file.


numFiles = length(timesFiles);
unitsTimeStamp = cell(numFiles, 1);
unitsWaveForm = cell(numFiles, 1);
unitsWaveFormMean = cell(numFiles, 1);
electrodeIndex = cell(numFiles, 1);

parfor i = 1:numFiles

    fprintf('loadSpikes: %s\n', timesFiles{i});

    timesFileObj = matfile(timesFiles{i});
    spikeClass = timesFileObj.cluster_class(:, 1);
    spikeTimestamps = timesFileObj.cluster_class(:, 2)';

    spikesFilesObj = matfile(spikesFiles{i});
    spikes = spikesFilesObj.spikes;
    spikes(timesFileObj.spikeIdxRejected, :) = [];
    
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
    
    fprintf('unit:');
    for u = 1:length(units)
        fprintf(' %d...', units(u));
    
        unitsTimeStampi{u} = spikeTimestamps(spikeClass==units(u));
        unitsWaveFormi{u} = spikes(spikeClass==units(u), :);
        unitsWaveFormMeani{u} = mean(spikes(spikeClass==units(u), :))';
    end
    fprintf('\n');

    unitsTimeStamp{i} = unitsTimeStampi;
    unitsWaveForm{i} = unitsWaveFormi;
    unitsWaveFormMean{i} = unitsWaveFormMeani;
    electrodeIndex{i} = unitsLabeli;

end

unitsTimeStamp = flatten(unitsTimeStamp);
unitsWaveForm = flatten(unitsWaveForm);
electrodeIndex = flatten(electrodeIndex);
unitsWaveFormMean = cell2mat(flatten(unitsWaveFormMean))';


