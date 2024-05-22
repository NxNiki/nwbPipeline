function [spikeCodes, spikeHist, spikeHistPrecise, binEdges1, binEdgesPrecise] = getSpikeCodes(spikes, spikeTimestamp, duration, par, inputStruct)

binEdges1 = 0:3:1000*(duration)+3;
binEdgesPrecise = 0:2000/par.sr:1000*(duration)+1;

if isempty(spikeTimestamp)
    spikeHist = zeros(1, length(binEdges1)-1); 
    spikeHistPrecise = zeros(1, length(binEdgesPrecise));
    [spikeCodes] = deal([]);
    return
end

w_pre = par.w_pre;
% Calculate and store spike features that can be used for rejection
spikeCodes = table();

ts = single(spikeTimestamp(:));
if length(unique(ts)) ~= length(spikeTimestamp)
    spikeCodes.timestamp_sec = spikeTimestamp(:);
else
    spikeCodes.timestamp_sec = ts;
end

%calculate firing rate
spikeCodes.firingRateAroundSpikeTime = calculateFiringRate(spikeTimestamp);

% local minima:
spikeCodes.rawAmplitude = spikes(:, w_pre);
spikeCodes.ampAsMultipleOfSTD = spikes(:, w_pre) / inputStruct.noise_std_detect;
locMin = diff(sign(diff(spikes')))'>0;
locMin = [ones(size(locMin,1),1), locMin, ones(size(locMin,1),1)];

localMinInd_Pre = nan(size(spikeCodes.rawAmplitude)); 
localMinV_Pre = localMinInd_Pre;

localMinInd_Post = nan(size(spikeCodes.rawAmplitude)); 
localMinV_Post = localMinInd_Post;
halfWidth = localMinInd_Pre;

for i = 1:length(localMinInd_Pre)
    localMinInd_Pre(i) = find(locMin(i,1:w_pre-1),1,'last');
    localMinV_Pre(i) = spikes(i,localMinInd_Pre(i));
    localMinInd_Post(i) = find(locMin(i,w_pre+1:end),1,'first')+w_pre;
    localMinV_Post(i) = spikes(i,localMinInd_Post(i));
    halfHeight = (spikes(i,w_pre) - localMinV_Pre(i))/2;
    [~,halfHeightPreInd] = min(abs(spikes(i,localMinInd_Pre(i):w_pre)-halfHeight));
    halfHeightPreInd = halfHeightPreInd+localMinInd_Pre(i);
    [~,halfHeightPostInd] = min(abs(spikes(i,w_pre:localMinInd_Post(i))-halfHeight));
    halfHeightPostInd = halfHeightPostInd+w_pre-1;
    halfWidth(i) = halfHeightPostInd-halfHeightPreInd;
end

spikeCodes.heightToWidthRatio = spikes(:,w_pre)./halfWidth;
spikeCodes.minToMinWidth = localMinInd_Post-localMinInd_Pre;
spikeCodes.localMinInd_Pre = localMinInd_Pre;
spikeCodes.localMinV_Pre = localMinV_Pre;
spikeCodes.localMinInd_Post = localMinInd_Post;
spikeCodes.localMinV_Post = localMinV_Post;
spikeCodes.halfWidth = halfWidth;

binEdges2 = 1.5:3:1000*(duration)+4.5;
spikeHist1 = logical(histcounts(spikeTimestamp, binEdges1));
spikeHist2 = logical(histcounts(spikeTimestamp, binEdges2));
clear binEdges2
spikeHist = spikeHist1 | spikeHist2;
clear spikeHist1 spikeHist2

spikeHistPrecise = logical(histc(spikeTimestamp, binEdgesPrecise));

end

function firingRateAroundSpikeTime = calculateFiringRate(spikeTimestamp)
    spikeTimestamp = spikeTimestamp - spikeTimestamp(1);
    binEdges1 = 0:500:500*floor(max(spikeTimestamp)/500)+500; 
    hist1 = histcounts(spikeTimestamp, binEdges1);
    spikeCount1 = hist1(max([ones(1, length(spikeTimestamp));floor(spikeTimestamp/500)], [], 1));

    binEdges2 = 250:500:500*floor((max(spikeTimestamp)+250)/500)+500;
    hist2 = histcounts(spikeTimestamp, binEdges2);
    spikeCount2 = hist2(max([ones(1, length(spikeTimestamp));ceil((spikeTimestamp-250)/500)], [], 1));

    firingRateAroundSpikeTime = .5*max([spikeCount1', spikeCount2'], [], 2);
end