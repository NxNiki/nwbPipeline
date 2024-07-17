function cluster_class = rejectPositiveSpikes(spikes, cluster_class)
% set cluster_class to 0 for positive spikes if its number is no larger
% than 10 times that of the negative spikes.

if size(spikes, 1) ~= size(cluster_class, 1)
    error('size of spikes and cluster_class not match!')
end

spikeIdx = cluster_class(1, :) > 0;

% calcualte the number of pos and neg spikes:
spikeMean = mean(spikes, 2);
spikeMedian = median(spikes, 2);

posSpikes = spikeMean > spikeMedian;
negSpikes = spikeMean <= spikeMedian;

if sum(posSpikes(spikeIdx)) > sum(negSpikes(spikeIdx)) * 10
    % keep positive spikes:
    cluster_class(negSpikes) = 0;
else
    cluster_class(posSpikes) = 0;
end

end