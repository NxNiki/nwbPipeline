function [spikeStartIndex, spikeEndIndex] = findSpikeIndex(signal, spike, searchRange)

if nargin < 3
    searchRange = [1, length(signal)];
end

% Find the starting index of the spike in the longer signal using cross-correlation
[maxCorr, spikeStartIndex] = max(sliding_window_correlation(spike, signal(searchRange(1): searchRange(2))));

if maxCorr < .99
    warning('spike may not exist on signal, max correlation: %d', maxCorr)
end

spikeStartIndex = searchRange(1) + spikeStartIndex - 1;
spikeEndIndex = spikeStartIndex + length(spike) - 1;
end

function correlations = sliding_window_correlation(x, y)
    window_size = length(x);
    % Initialize array to store correlations
    num_segments = (length(y) - window_size) + 1;
    correlations = zeros(1, num_segments);
    
    % Calculate correlation for each segment
    for i = 1:num_segments
        y_segment = y(i:i+window_size-1);
        correlations(i) = corr(x', y_segment', 'type', 'Pearson');
    end
end

