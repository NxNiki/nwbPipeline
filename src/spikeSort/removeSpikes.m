function signalSpikeRemoved = removeSpikes(signal, signalTimestamps, spikes, spikeClass, spikeTimestamps, inludeClass0)
% remove spikes in the csc signal:

if nargin < 6
    inludeClass0 = false;
end

if ~inludeClass0
    spikes = spikes(spikeClass ~= 0,:);
    spikeClass = spikeClass(spikeClass ~= 0);
end

spikeSignalCorrThresh = 0;
units = unique(spikeClass);
revertedSpikes = zeros(size(signal));


for u = 1:length(units)

    fprintf('remove spike for unit %d...\n', units(u));

    unitTs = spikeTimestamps(spikeClass==units(u));
    spikeIndexInSignal = interp1(signalTimestamps, 1:length(signalTimestamps), unitTs, 'nearest');

    if all(isnan(spikeIndexInSignal))
        warning('spike and signal timestamp miss match!')
        signalTimestamps = (signalTimestamps - signalTimestamps(1)) * 1000;
        spikeIndexInSignal = interp1(signalTimestamps, 1:length(signalTimestamps), unitTs, 'nearest');
    end

    if sum(isnan(spikeIndexInSignal))>5
        warning('unexpected number of nan timestamps discovered.')
        unitTs(isnan(spikeIndexInSignal)) = [];
        spikeIndexInSignal(isnan(spikeIndexInSignal)) = [];
    else
        unitTs(isnan(spikeIndexInSignal)) = [];
        spikeIndexInSignal(isnan(spikeIndexInSignal)) = [];
    end

    unitSpikes = spikes(spikeClass==units(u),:);
    unitAvgSpike = mean(unitSpikes);

    [~, avgPeakInd] = max(abs(unitAvgSpike - median(unitAvgSpike)));
    fprintf('peak index of spike: %d\n', avgPeakInd);

    % add a gradual taper to the waveform so that there isn't an
    % abrupt cliff at the edges.
    padWidth = floor(length(unitAvgSpike)/2);
    prePad = linspace(0, unitAvgSpike(1), padWidth+1);
    prePad(end) = [];
    postPad = linspace(unitAvgSpike(end), 0, padWidth+1);
    postPad(1) = [];
    avgPeakInd = avgPeakInd + padWidth;
    unitAvgSpikePad = [prePad, unitAvgSpike, postPad];

    maxTolerance = 22;
    for t = 1:length(unitTs)
        unitIdx = colonByLength(spikeIndexInSignal(t) - avgPeakInd + 1, 1, length(unitAvgSpikePad));
        unitIdx(unitIdx < 1 | unitIdx > length(signalTimestamps)) = nan;

        unitSignalSpike = signal(unitIdx((avgPeakInd - maxTolerance): (avgPeakInd + maxTolerance)));
        [~, spikePeak] = max(abs(unitSignalSpike - median(unitSignalSpike))); % find index that spike peaks
        newPeakInd = spikePeak + avgPeakInd - maxTolerance - 1;
        if newPeakInd ~= avgPeakInd
            unitIdx = colonByLength(spikeIndexInSignal(t) - avgPeakInd + (newPeakInd - avgPeakInd), 1, length(unitAvgSpikePad));
            indsToKeep = unitIdx>=1 & unitIdx<=length(signalTimestamps);
        else
            indsToKeep = ~isnan(unitIdx); %true(size(wav)); need to eliminate those past length(lfpTS)
        end

        % ----------------- uncomment and set break point to compare signals with spikes:
        % spikeInSignalIdxStart = spikeIndexInSignal(t) - 23 + 1;
        % spikeInSignal = signal(spikeInSignalIdxStart: spikeInSignalIdxStart + length(spikes(t,:)) - 1);
        % plot([unitSpikes(t,:)', spikeInSignal(:) - mean(spikeInSignal), unitAvgSpike(:)])
        % legend({'unitSpike', 'spikeInSignal', 'unitAvgSpike'})
        % -----------------

        spikeSignalCorr = corr(signal(unitIdx(indsToKeep))', unitAvgSpikePad(indsToKeep)');
        isInverted = ((spikeSignalCorr < 0) - .5) * 2; % if correlation < 0 isInverted is 1 else -1.
        isInverted = isInverted * (abs(spikeSignalCorr) > spikeSignalCorrThresh);

        revertedSpikes(unitIdx(indsToKeep)) = revertedSpikes(unitIdx(indsToKeep)) - isInverted * unitAvgSpikePad(indsToKeep);
    end
end

signalSpikeRemoved = signal - revertedSpikes; % the spikes are reverted so we add it to the raw signal.

end

function v = colonByLength(start,increment,length)
v = start:increment:((length-1)*increment+start);
end
