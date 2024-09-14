function [spikeStartIndex, spikeEndIndex] = findSpikeIndex(signal, spike, searchRange)
% this is not used.
% Xin

if nargin < 3
    searchRange = [1, length(signal)];
end

% Find the starting index of the spike in the longer signal using cross-correlation
[maxCorr, spikeStartIndex] = max(xcorr(spike, signal(searchRange(1): searchRange(2))));

if maxCorr < .99
    warning('spike not found on signal, max correlation: %d', maxCorr)
end

spikeStartIndex = searchRange(1) + spikeStartIndex - 1;
spikeEndIndex = spikeStartIndex + length(spike) - 1;
