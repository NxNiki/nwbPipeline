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
        keyboard
        unitTs(isnan(unitPeakIdxInSignal)) = [];
        unitPeakIdxInSignal(isnan(unitPeakIdxInSignal)) = [];
    else
        unitTs(isnan(unitPeakIdxInSignal)) = [];
        unitPeakIdxInSignal(isnan(unitPeakIdxInSignal)) = [];
    end

    unitAvgSpike = mean(spikes(spikeClass==units(u),:));

    [~, avgPeakInd] = max(abs(unitAvgSpike));
    fprintf('peak index of spike: %d\n', avgPeakInd);

    % add a gradual taper to the waveform so that there isn't an
    % abrupt cliff at the edges.
    padWidth = floor(length(unitAvgSpike)/2);
    prePad = linspace(0, unitAvgSpike(1), padWidth+1); 
    prePad(end) = [];
    postPad = linspace(unitAvgSpike(end), 0, padWidth+1);
    postPad(1) = [];
    avgPeakInd = avgPeakInd + padWidth;
    unitAvgSpike = [prePad, unitAvgSpike, postPad];

    maxTolerance = 22;
    for t = 1:length(unitTs)
        unitIdx = colonByLength(unitPeakIdxInSignal(t)-avgPeakInd, 1, length(unitAvgSpike));
        unitIdx(unitIdx<1) = nan;
        unitIdx(unitIdx>length(signalTimestamps)) = nan;
        unitSignalSpike = signal(unitIdx((avgPeakInd - maxTolerance): (avgPeakInd + maxTolerance)));
        [~, spikePeak] = min(unitSignalSpike); % find index that spike peaks
        newPeakInd = spikePeak + avgPeakInd - maxTolerance - 1;
        if newPeakInd ~= avgPeakInd
            unitIdx = colonByLength(unitPeakIdxInSignal(t) - avgPeakInd + (newPeakInd-avgPeakInd), 1, length(unitAvgSpike));
            indsToKeep = unitIdx>=1 & unitIdx<=length(signalTimestamps);
        else
            indsToKeep = ~isnan(unitIdx); %true(size(wav)); need to eliminate those past length(lfpTS)
        end
        negativeSpikes(unitIdx(indsToKeep)) = negativeSpikes(unitIdx(indsToKeep)) - unitAvgSpike(indsToKeep); % negative spikes is all 0s so this flips the spike
    end
end

signal = signal + negativeSpikes; % !!! need to confirm the spikes are NOT reverted !!!

end

function v = colonByLength(start,increment,length)
v = start:increment:((length-1)*increment+start);
end