function [unitsTimeStamp, unitsWaveForm, unitsWaveFormMean, electrodeIndex] = loadSpikes(spikeFilePath)
% read units in spike files and concatenate timestamps, waveform, and file
% name in a one dimensional cell array.
% this is used to save spikes into nwb file.

spikeFiles = listFiles(spikeFilePath, '*_spikes.mat', '^\._');

numFiles = length(spikeFiles);
unitsTimeStamp = cell(numFiles, 1);
unitsWaveForm = cell(numFiles, 1);
unitsWaveFormMean = cell(numFiles, 1);
electrodeIndex = cell(numFiles, 1);

parfor i = 1:numFiles

    fprintf('loadSpikes: %s\n', spikeFiles{i});

    [~, spikeFileName] = fileparts(spikeFiles{i});
    timesFile = fullfile(spikeFilePath, ['times_', strrep(spikeFileName, '_spikes.mat', '.mat')])

    spikesFilesObj = matfile(spikeFiles{i});
    spikes = spikesFilesObj.spikes;

    if exist(timesFile, "file")

        timesFileObj = matfile(timesFile);
        spikeClass = timesFileObj.cluster_class(:, 1);
        spikeTimestamps = timesFileObj.cluster_class(:, 2)';

        spikes(timesFileObj.spikeIdxRejected, :) = [];

        % remove un-clustered spikes:
        spikes = spikes(spikeClass ~= 0,:);
        spikeClass = spikeClass(spikeClass ~= 0);

    else
        warning('times file not exist: %s\n', timesFile);
        spikeClass = ones(size(spikes, 1), 1);
        spikeTimestamps = spikesFilesObj.spikeTimestamps
    end

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
        unitsWaveFormMeani{u} = mean(spikes(spikeClass==units(u), :), 1)';
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
