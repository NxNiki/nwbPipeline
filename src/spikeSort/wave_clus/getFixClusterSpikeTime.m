function [spikeTime1, spikeTime2] = getFixClusterSpikeTime(clustersFixedIdx, USER_DATA)

if length(clustersFixedIdx) ~= 2
    errordlg('Please select 2 clusters to create cross correlogram!', 'Error');
    return
end

spike_class = USER_DATA{6};
spikeTimestamps = USER_DATA{3};

spike_class = spike_class(:);
spikeTimestamps = spikeTimestamps(:)/1000;

spikeTime1 = spikeTimestamps(spike_class == clustersFixedIdx(1));
spikeTime2 = spikeTimestamps(spike_class == clustersFixedIdx(2));