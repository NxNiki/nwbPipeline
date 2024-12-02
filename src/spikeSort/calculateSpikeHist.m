function [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, binEdges1, binEdgesPrecise)

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
