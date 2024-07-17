function cluster_class = rejectPositiveSpikes(spikes, cluster_class, par)
% set cluster_class to 0 for positive spikes if its number is no larger
% than 10 times that of the negative spikes.

if size(spikes, 1) ~= size(cluster_class, 1)
    error('size of spikes and cluster_class not match!')
end

spikeIdx = cluster_class(:, 1) > 0;
peakWindow = par.w_pre - 5: par.w_pre + 5;
% calcualte the number of pos and neg spikes:
spikePeakMean = mean(spikes(:, peakWindow), 2);
% spikeMedian = median(spikes, 2);

posSpikes = spikePeakMean > 0;
negSpikes = spikePeakMean <= 0;

if sum(posSpikes(spikeIdx)) > sum(negSpikes(spikeIdx)) * 10
    % keep positive spikes:
    cluster_class(negSpikes, 1) = 0;
else
    cluster_class(posSpikes, 1) = 0;
end

end