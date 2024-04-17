function signal = removeSpikes(signal, signalTimestamps, spikes, spikeClass, spikeTimestamps, inludeClass0)
% remove spikes in the csc signal:

if nargin < 6
    inludeClass0 = false;
end

if ~inludeClass0
    spikes = spikes(spikeClass ~= 0,:);
    spikeClass = spikeClass(spikeClass ~= 0);
end

units = unique(spikeClass);
negativeSpikes = zeros(size(signal));
for u = 1:length(units)
    fprintf('remove spike for unit %d...\n', u);

    unitTs = spikeTimestamps(spikeClass==units(u));
    unitPeakIdxInSignal = interp1(signalTimestamps, 1:length(signalTimestamps), unitTs, 'nearest');

    if sum(isnan(unitPeakIdxInSignal))>5
        warning('unexpected number of nan timestamps discovered.')
        unitPeakIdxInSignal(isnan(unitPeakIdxInSignal)) = [];
    else
        unitPeakIdxInSignal(isnan(unitPeakIdxInSignal)) = [];
    end

    unitSpikes = spikes(spikeClass==units(u),:);
    unitAvgSpike = mean(unitSpikes);

    [~, avgPeakInd] = max(abs(unitAvgSpike));
    fprintf('peak index of spike: %d\n', avgPeakInd);

    % add a gradual taper to the waveform so that there isn't an
    % abrupt cliff at the edges.
    padWidth = floor(length(unitAvgSpike)/2);
    prePad = linspace(0, unitAvgSpike(1), padWidth+1); 
    prePad(end) = [];
    postPad = linspace(unitAvgSpike(end), 0, padWidth+1);
    postPad(1) = [];

    searchRange = max(100, avgPeakInd); % number of sample before and after peak to search for spike index in signal.
    for t = 1:length(unitPeakIdxInSignal)
        [spikeStartIndex, spikeEndIndex] = findSpikeIndex(signal, unitSpikes(t,:), [unitPeakIdxInSignal(t) - searchRange, unitPeakIdxInSignal(t) + searchRange]);
        spikeStartIndex = spikeStartIndex - length(prePad);
        spikeEndIndex = spikeEndIndex + length(postPad);
        negativeSpikes(spikeStartIndex: spikeEndIndex) = negativeSpikes(spikeStartIndex: spikeEndIndex) - [prePad, unitAvgSpike, postPad]; % negative spikes is all 0s so this flips the spike
    end
end

signal = signal + negativeSpikes; % !!! need to confirm the spikes are NOT reverted !!!

end
