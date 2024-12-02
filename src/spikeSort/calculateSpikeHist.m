function [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, duration, samplingRate)

    fprintf('create spike hist, duration: %s seconds, sampling rate: %d Hz\n', num2str(duration), samplingRate);

    [binEdges1, binEdgesPrecise] = createBinEdge(duration, samplingRate);
    binEdges2 = binEdges1+1.5;

    if isempty(spikeTimestamps)
        spikeHist = zeros(1, length(binEdges1)-1);
        spikeHistPrecise = zeros(1, length(binEdgesPrecise)-1);
        return
    end

    % convert spike time stamps to milliseconds:
    spikeTimestamps = (spikeTimestamps - spikeTimestamps(1)) * 1000;
    spikeHist1 = logical(histcounts(spikeTimestamps, binEdges1));
    spikeHist2 = logical(histcounts(spikeTimestamps, binEdges2));
    spikeHist = spikeHist1 | spikeHist2;

    % this needs huge memory for mutli-exp analysis with duration larger
    % than 17 hours. consider process each exp/segment separately and
    % append result iteratively.
    spikeHistPrecise = logical(histcounts(spikeTimestamps, binEdgesPrecise));

end
