function [spikeTime1, spikeTime2] = getFixClusterSpikeTime(clustersFixedIdx)

if length(clustersFixedIdx) ~= 2
    errordlg('Please select 2 clusters to create cross correlogram!', 'Error');
    return
end

[spikeTimestamps, spike_class] = getUserData([3, 6]);

spike_class = spike_class(:);
spikeTimestamps = spikeTimestamps(:)/1000;

spikeTime1 = spikeTimestamps(spike_class == clustersFixedIdx(1));
spikeTime2 = spikeTimestamps(spike_class == clustersFixedIdx(2));