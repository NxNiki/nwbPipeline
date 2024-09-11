function [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, duration, samplingRate)
    binEdges1 = 0:3:1000*(duration)+3;
    binEdgesPrecise = 0:2000/samplingRate:1000*(duration)+1;
    binEdges2 = 1.5:3:1000*(duration)+4.5;
    
    if isempty(spikeTimestamps)
        spikeHist = zeros(1, length(binEdges1)-1); 
        spikeHistPrecise = zeros(1, length(binEdgesPrecise));
        return
    end

    % convert spike time stamps to milliseconds:
    spikeTimestamps = (spikeTimestamps - spikeTimestamps(1)) * 1000;
    spikeHist1 = logical(histcounts(spikeTimestamps, binEdges1));
    spikeHist2 = logical(histcounts(spikeTimestamps, binEdges2));
    spikeHist = spikeHist1 | spikeHist2;
    
    spikeHistPrecise = logical(histc(spikeTimestamps, binEdgesPrecise));

end