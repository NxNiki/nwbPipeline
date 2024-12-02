function [binEdges, binEdgesPrecise] = createBinEdge(duration, samplingRate)
% create bin edges to count number of spikes in each bin.
% duration should be in seconds and will be converted to milliseconds.

binEdges = 0:3:1000*(duration)+3;
binEdgesPrecise = single(0:2000/samplingRate:1000*(duration)+1);
