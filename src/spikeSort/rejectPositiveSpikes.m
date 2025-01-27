function cluster_class = rejectPositiveSpikes(spikes, cluster_class, par)
% set cluster_class to 0 for positive spikes if its number is no larger
% than 10 times that of the negative spikes.

if nargin < 3
    par = [];
end

if size(spikes, 1) ~= length(cluster_class)
    error('size of spikes and cluster_class not match!')
end

% calcualte the number of pos and neg spikes:
if ~isempty(par) && length(par.w_pre) == 1
    peakWindow = par.w_pre - 5: par.w_pre + 5;
else
    peakWindow = getSpikePeakWindow(spikes);
end
peakWindow(peakWindow > size(spikes, 2)) = [];
peakWindow(peakWindow < 1) = [];

spikePeakMean = mean(spikes(:, peakWindow), 2);
posSpikes = spikePeakMean > 0;
negSpikes = spikePeakMean <= 0;

clusterIndices = unique(cluster_class(cluster_class > 0));
for i = 1:length(clusterIndices)
    spikeIdx = cluster_class == clusterIndices(i);

    if sum(spikeIdx) < 100
        continue
    end

    if sum(posSpikes(spikeIdx)) > sum(negSpikes(spikeIdx)) * 10
        % keep positive spikes if their number is larger than 10 times of
        % the negative ones:
        cluster_class(negSpikes(:) & spikeIdx(:)) = 0;
    else
        cluster_class(posSpikes(:) & spikeIdx(:)) = 0;
    end

end
