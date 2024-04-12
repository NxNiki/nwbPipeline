function signal = removeSpikes(signal, signalTimestamps, spikes, spikeClass, spikeTimestamps)
% remove spikes in the csc signal:

% samplingInterval = mean(diff(signalTimestamps));
% sr = 1 / samplingInterval;

unitNums = length(unique(spikeClass));
negativeSpikes = zeros(size(signal));
for u = 1:length(unitNums)
    fprintf('remove spike for unit %d...\n', u);

    ts = spikeTimestamps(classes==unitNums(u));
    tsInd = interp1(signalTimestamps, 1:length(signalTimestamps), ts, 'nearest');

    if sum(isnan(tsInd))>5
        warning('unexpected number of nan timestamps discovered.')
        keyboard
        ts(isnan(tsInd)) = [];
        tsInd(isnan(tsInd)) = [];
    else
        ts(isnan(tsInd)) = [];
        tsInd(isnan(tsInd)) = [];
    end

    wav = mean(spikes(spikeClass==unitNums(u),:));

    [~,peakInd] = max(wav);
    fprintf('peak index of spike: %d\n', peakInd);

    % add a gradual taper to the waveform so that there isn't an
    % abrupt cliff at the edges.
    padWidth = floor(length(wav)/2);
    prePad = linspace(0, wav(1), padWidth+1); 
    prePad(end) = [];
    postPad = linspace(wav(end), 0, padWidth+1);
    postPad(1) = [];
    peakInd = peakInd + padWidth;
    wav = [prePad, wav, postPad];

    maxTolerance = 22;
    for t = 1:length(ts)
        theseInds = colonByLength(tsInd(t)-peakInd,1,length(wav));
        theseInds(theseInds<1) = nan;
        theseInds(theseInds>length(lfpTS)) = nan;
        [~,spikePeak] = min(signal(theseInds((peakInd-maxTolerance):(peakInd+maxTolerance)))); % find index that spike peaks
        newPeakInd = spikePeak + peakInd - maxTolerance - 1;
        if newPeakInd ~= peakInd
            theseInds = colonByLength(tsInd(t)-peakInd+(newPeakInd-peakInd), 1, length(wav));
            indsToKeep = theseInds>=1 & theseInds<=length(signalTimestamps);
        else
            indsToKeep = ~isnan(theseInds); %true(size(wav)); need to eliminate those past length(lfpTS)
        end
        negativeSpikes(theseInds(indsToKeep)) = negativeSpikes(theseInds(indsToKeep)) - wav(indsToKeep); % negative spikes is all 0s so this flips the spike
    end
end

signal = signal - negativeSpikes;

end

function v = colonByLength(start,increment,length)
v = start:increment:((length-1)*increment+start);
end