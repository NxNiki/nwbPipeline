function [spikes,thr,index,spikeCodes,spikeHist,spikeHistPrecise, binEdges1, binEdgesPrecise] = amp_detect_AS(x, par, maxAmp, TimeStamps, duration, thr, inputStruct)
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.

if length(x(:)) ~= length(TimeStamps(:))
    error('voltage signal (%d) and time stamp (%d) do not have same length.', length(x(:)), length(TimeStamps(:)))
end

sr = par.sr;
w_pre = par.w_pre;
w_post = par.w_post;
ref = par.ref;
detect = par.detection;
stdmin = par.stdmin;
stdmax = par.stdmax;
fmin_detect = par.detect_fmin;
fmax_detect = par.detect_fmax;
fmin_sort = par.sort_fmin;
fmax_sort = par.sort_fmax;

if exist('inputStruct','var') && ~isempty(inputStruct)
    %the data has already been loaded and filtered in a previous step and
    %passed here.
    xf = inputStruct.xf;
    xf_detect = inputStruct.xf_detect;
    noise_std_detect = inputStruct.noise_std_detect;
    noise_std_sorted = inputStruct.noise_std_sorted;
    thrmax = inputStruct.thrmax;
    if ~exist('thr','var') || isempty(thr)
        thr = inputStruct.thr;
    end
else
    %HIGH-PASS FILTER OF THE DATA
    if exist('ellip','file')                  %Checks for the signal processing toolbox
        [b_detect, a_detect] = ellip(par.detect_order, 0.1, 40, [fmin_detect fmax_detect]*2/sr);
        [b,a] = ellip(par.sort_order,0.1,40,[fmin_sort fmax_sort]*2/sr);

        xf_detect = filtfilt(b_detect, a_detect, x);
        xf = filtfilt(b, a, x);

    else
        xf = fix_filter(x);                   %Does a bandpass filtering between [300 3000] without the toolbox.
        xf_detect = xf;
    end

    noise_std_detect = median(abs(xf_detect))/0.6745;
    noise_std_sorted = median(abs(xf))/0.6745;
    if ~exist('thr','var') || isempty(thr)
        thr = stdmin * noise_std_detect;        %thr for detection is based on detect settings.
    end
    thrmax = min(maxAmp, stdmax * noise_std_sorted);     %thrmax for artifact removal is based on sorted settings.
end

index = [];
sample_ref = floor(ref/2);
% LOCATE SPIKE TIMES
switch detect
    case 'pos'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2-sample_ref) > thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = max((xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((xf(xaux(i)+1:xaux(i)+sample_ref))>thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'neg'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2-sample_ref) < -thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = min((xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((xf(xaux(i)+1:xaux(i)+sample_ref))<thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'both'
        nspk = 0;
        xaux = find(abs(xf_detect(w_pre+2:end-w_post-2-sample_ref)) > thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = max(abs(xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((abs(xf(xaux(i)+1:xaux(i)+sample_ref)))>thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
end

% SPIKE STORING (with or without interpolation)
ls = w_pre+w_post;
spikes = zeros(nspk,ls+4);
rejectedSpikes = spikes;

xf(length(xf)+1:length(xf)+w_post)=0;

for i=1:nspk                          %Eliminates artifacts
    if max(abs( xf(index(i)-w_pre:index(i)+w_post) )) < thrmax
        spikes(i,:)=xf(index(i)-w_pre-1:index(i)+w_post+2);
    else
        rejectedSpikes(i,:) = xf(index(i)-w_pre-1:index(i)+w_post+2);
    end
end
aux = find(spikes(:,w_pre)==0);       %erases indexes that were artifacts
spikes(aux,:)=[];
index(aux)=[];

switch par.interpolation
    case 'n'
        spikes(:,end-1:end)=[];       %eliminates borders that were introduced for interpolation
        spikes(:,1:2)=[];
    case 'y'
        %Does interpolation
        spikes = int_spikes(spikes,par);
end

if isempty(index)
    binEdges1 = 0:3:1000*(duration)+3;
    binEdgesPrecise = 0:2000/sr:1000*(duration)+1;
    spikeHist = zeros(1, length(binEdges1)-1); 
    spikeHistPrecise = zeros(1, length(binEdgesPrecise));
    [spikes,thr,index,spikeCodes] = deal([]);
    return
end

%% Calculate and store spike features that can be used for rejection
rawAmplitude = spikes(:, w_pre);
ampAsMultipleOfSTD = spikes(:, w_pre) / noise_std_detect;


tIndex = TimeStamps(index)*1000;
%calculate firing rate
if nspk==0
    firingRateAroundSpikeTime = zeros(0,1);
else
    binEdges1 = 0:500:500*floor(max(tIndex)/500)+500; 
    binEdges2 = 250:500:500*floor((max(tIndex)+250)/500)+500;
    hist1 = histcounts(tIndex, binEdges1); hist2 = histcounts(tIndex, binEdges2);
    spikeCount1 = hist1(max([ones(1, length(tIndex));floor(tIndex/500)], [], 1));
    spikeCount2 = hist2(max([ones(1, length(tIndex));ceil((tIndex-250)/500)], [], 1));
    firingRateAroundSpikeTime = .5*max([spikeCount1', spikeCount2'], [], 2);
end

timestamp_sec = tIndex(:)/1000;

%% local minima:
locMin = diff(sign(diff(spikes')))'>0;
locMin = [repmat(1,size(locMin,1),1), locMin, repmat(1,size(locMin,1),1)];
localMinInd_Pre = nan(size(rawAmplitude)); localMinV_Pre = localMinInd_Pre;
localMinInd_Post = nan(size(rawAmplitude)); localMinV_Post = localMinInd_Post;
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

heightToWidthRatio = spikes(:,w_pre)./halfWidth;
minToMinWidth = localMinInd_Post-localMinInd_Pre;
%%

spikeCodes = table(timestamp_sec,firingRateAroundSpikeTime,...
    rawAmplitude,ampAsMultipleOfSTD,localMinInd_Pre,localMinV_Pre,localMinInd_Post,localMinV_Post,...
    halfWidth, heightToWidthRatio,minToMinWidth);

binEdges1 = 0:3:1000*(duration)+3; 
binEdges2 = 1.5:3:1000*(duration)+4.5;
spikeHist1 = logical(histcounts(tIndex, binEdges1));
spikeHist2 = logical(histcounts(tIndex, binEdges2));
spikeHist = spikeHist1 | spikeHist2;

binEdgesPrecise = 0:2000/sr:1000*(duration)+1;
spikeHistPrecise = logical(histc(tIndex, binEdgesPrecise));

