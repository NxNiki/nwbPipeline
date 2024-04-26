function [unitsTimeStamp, unitsWaveForm] = loadSpikes(spikeFiles)

numFiles = length(spikeFiles);

spikeFileObj = matfile(spikeFile);
spikes = spikeFileObj.spikes;
spikeClass = spikeFileObj.cluster_class(:, 1);
spikeTimestamps = spikeFileObj.cluster_class(:, 2);

% remove un-clustered spikes:
spikes = spikes(spikeClass ~= 0,:);
spikeClass = spikeClass(spikeClass ~= 0);

units = unique(spikeClass);
unitsTimeStamp = cell(length(units), 1);
unitsWaveForm = cell(lenght(units), 1);

for u = 1:length(units)
    fprintf('load spike unit %d...\n', units(u));

    unitsTimeStamp{u} = spikeTimestamps(spikeClass==units(u));
    unitsWaveForm{u} = spikes(spikeClass==units(u), :);
end

