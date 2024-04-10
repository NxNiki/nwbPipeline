function [inds, rejectionThresh, spikeCodes, probabilityParams] = getSpikesToReject(spikeCodes, forceCompute, rejectionThresh, probParamsToOverwrite)

% This function is used to identify detected waveforms that are likely
% noise, rather than real spikes. It takes in spikeCodes, a variable that
% has several descriptors of the spikes and then determines which spikes
% violate reasonable parameters. The precise parameters are given in the
% probabilityParams struct (set inside the code), and have been chosen
% heuristically. You may disagree with these parameters and it would be
% worth a widespread discussion of what the best parameters are. For each
% parameter there is a range such that on one side of the range, the
% probability that a spike is real based on that one parameter is set at 1
% and on the other side it is set at 0. The probabilities are scaled in a
% sigmoid that crosses the range. At the end, a threshold for total
% probability (all individual probabilities multiplied) is computed, based
% on the CDF of the probabilities of all spikes (Or a pre-determined
% threshold may be passed in), and spikes with probability less than that
% are removed from consideration prior to clustering. (Rejected spikes are
% saved for future reference.)
%
% if forceCompute is false (default), it will only compute the
% probabilities that aren't already stored in spikeCodes. Otherwise, it
% will compute everything from scratch and overwrite. If you change the
% probabilityParams, you'll want to forceCompute.
%
% probParamsToOverwrite allows you to change specific parameters away from
% the defaults without changing the function itself. For example, 155-200
% is usually a good upper limit, but occasionally we find ceiling effects
% when there is an especially high amplitude unit. In this case, you could
% rerun the function with the argument {'amplitudeLR',[300 350]}. Their
% fields you can modify and their default values are as listed below. This
% argument expects parameter-value pairs.
%
% probabilityParams.amplitudeLR = [155 200];
% probabilityParams.firingRateLR = [90 150];
% probabilityParams.fractionConcurrentLR = [0.2 0.5];
% probabilityParams.locMinIndPreLR = [-2 -1];% Note that this results in all spikes having P=1 for this... [2 7];
% probabilityParams.locMinIndPostLR = [55 75];
% probabilityParams.locMinVLR1 = [-100 -80]; 
% probabilityParams.locMinVLR2 = [25 60];
% probabilityParams.heightToWidthRatioLR1 = lowEnd + [-5 0];
% probabilityParams.heightToWidthRatioLR2 = highEnd + [0 5];

if ~exist('forceCompute','var')||isempty(forceCompute)
    forceCompute = 0;
end

%%
% p is a sigmoid function that starts at 1, then decreases over a span of
% "span" with center c, to 0. So that p(c) is 0.5, and p(c-span/2) is
% approx (1) and p(c+span/2) is approx 0.
% P then extends that to a function with left and right endpoints, such
% that P(LR(1)) is appox 1, P(LR(2)) is approx (0), and the midpoint between l and
% r takes a value of 0.5.
% This is used as a way of assigning probability of being a "real" spike
% based on characteristics of the spike, without defining hard cutoffs.
% p2 and P2 are equivalents, but with high probability on high numbers
% instead of low.
% Pbump takes the minimum of P and P2, allowing for a high probability
% bump in a middle region with low probability on either side.

p = @(x,c,span)1-(1./(1+exp(-10*(x-c)/span)));
% P = @(x,LR)p(x,sum(LR)/2,diff(LR));
P = @(x,LR)max([double(x<LR(1));p(x,sum(LR)/2,diff(LR))]).*double(x<LR(2));
p2 = @(x,c,span)1./(1+exp(-10*(x-c)/span));
% P2 = @(x,LR)p2(x,sum(LR)/2,diff(LR));
P2 = @(x,LR)max([double(x>LR(2));p2(x,sum(LR)/2,diff(LR))]).*double(x>LR(1));
Pbump = @(x,LRlow,LRhigh)min([P2(x,LRlow);P(x,LRhigh)]);
%%
probabilityParams.description = 'These parameters were used to determine the probability that a spike was physiological, based on that parameter. See "getSpikesToReject" for further info.';
probabilityParams.amplitudeLR = [155 200];
probabilityParams.firingRateLR = [90 150];
probabilityParams.fractionConcurrentLR = [0.2 0.5];
probabilityParams.channelsConcurrentPreciseLR = [3 6];
probabilityParams.locMinIndPreLR = [-2 -1];% Note that this results in all spikes having P=1 for this... [2 7];
probabilityParams.locMinIndPostLR = [55 75];
probabilityParams.locMinVLR1 = [-100 -80]; 
probabilityParams.locMinVLR2 = [25 60];

% it looks like the height to width ratio usually has a concenctrated
% distribution, if there are tails that are separated from the distribution
% the spikes in the tails are generally not good. So we have to find the
% tails to determine the ratios.
[n, c] = histcounts(spikeCodes.heightToWidthRatio);
zeroSets = continuousRunsOfTrue(n<.02*max(n));
inds = zeroSets(:,2)-zeroSets(:,1) < 3; zeroSets(inds,:) = [];
cValZeros = c(zeroSets);
[~,peakInd] = max(n); peakVal = c(peakInd);
lowEnd = cValZeros(find(cValZeros(:,2)<peakVal,1,'last'),2);
if isempty(lowEnd), lowEnd = c(1)-1; end
highEnd = cValZeros(find(cValZeros(:,1)>peakVal,1,'first'),1);
if isempty(highEnd),highEnd = c(end)+1;end
    
probabilityParams.heightToWidthRatioLR1 = lowEnd + [-5 0];
probabilityParams.heightToWidthRatioLR2 = highEnd + [0 5];

% overwrite values if passed in
if exist('probParamsToOverwrite','var') && ~isempty(probParamsToOverwrite)
    assert(~mod(length(probParamsToOverwrite),2) && all(cellfun(@(x)ischar(x),probParamsToOverwrite(1:2:end))),...
        'probParamsToOverwrite should be passed in as parameter-value pairs');
    assert(all(ismember(probParamsToOverwrite(1:2:end),fieldnames(probabilityParams))),...
        'the parameter title must be one of the default fieldnames of probabilityParams. Please see documentation for more help.');
    fieldsToOverwrite = probParamsToOverwrite(1:2:end);
    newVals = probParamsToOverwrite(2:2:end);
    for k = 1:length(fieldsToOverwrite)
        probabilityParams.(fieldsToOverwrite{k}) = newVals{k};
    end
end

vars = spikeCodes.Properties.VariableNames;
recomputeAll = ~ismember('P_givenAll',vars);

if forceCompute || ~ismember('P_givenAmp',vars)
P_givenAmp = P(spikeCodes.rawAmplitude,probabilityParams.amplitudeLR);
spikeCodes = addToTable(spikeCodes,P_givenAmp,'P_givenAmp');
recomputeAll = 1;
end

if forceCompute || ~ismember('P_givenFR',vars)
P_givenFR = P(spikeCodes.firingRateAroundSpikeTime,probabilityParams.firingRateLR);
spikeCodes = addToTable(spikeCodes,P_givenFR,'P_givenFR');
recomputeAll = 1;
end

if ismember('fractionConcurrent',vars)
if forceCompute || ~ismember('P_givenConcurrent',vars)
P_givenConcurrent = P(spikeCodes.fractionConcurrent,probabilityParams.fractionConcurrentLR);
P_givenConcurrent(isnan(spikeCodes.fractionConcurrent)) = 1;
spikeCodes = addToTable(spikeCodes,P_givenConcurrent,'P_givenConcurrent');
recomputeAll = 1;
end
else
    P_givenConcurrent = ones(size(spikeCodes.P_givenFR));
    spikeCodes = addToTable(spikeCodes,P_givenConcurrent,'P_givenConcurrent');
end

if ismember('channelsConcurrentPrecise',vars)
if forceCompute || ~ismember('P_givenConcurrentPrecise',vars)
P_givenConcurrentPrecise = P(spikeCodes.channelsConcurrentPrecise,probabilityParams.channelsConcurrentPreciseLR);
P_givenConcurrentPrecise(isnan(spikeCodes.channelsConcurrentPrecise)) = 1;
spikeCodes = addToTable(spikeCodes,P_givenConcurrentPrecise,'P_givenConcurrentPrecise');
recomputeAll = 1;
end
else
    P_givenConcurrentPrecise = ones(size(spikeCodes.P_givenFR));
    spikeCodes = addToTable(spikeCodes,P_givenConcurrentPrecise,'P_givenConcurrentPrecise');
end

if forceCompute || ~ismember('P_givenLocMinIndPre',vars)
P_givenLocMinIndPre = P2(spikeCodes.localMinInd_Pre,probabilityParams.locMinIndPreLR);
spikeCodes = addToTable(spikeCodes,P_givenLocMinIndPre,'P_givenLocMinIndPre');
recomputeAll = 1;
end

if forceCompute || ~ismember('P_givenLocMinIndPost',vars)
P_givenLocMinIndPost = P(spikeCodes.localMinInd_Post,probabilityParams.locMinIndPostLR);
spikeCodes = addToTable(spikeCodes,P_givenLocMinIndPost,'P_givenLocMinIndPost');
recomputeAll = 1;
end

if forceCompute || ~ismember('P_givenLocMinVPre',vars)
P_givenLocMinVPre = Pbump(spikeCodes.localMinV_Pre',probabilityParams.locMinVLR1,probabilityParams.locMinVLR2)';
spikeCodes = addToTable(spikeCodes,P_givenLocMinVPre,'P_givenLocMinVPre');
recomputeAll = 1;
end

if forceCompute || ~ismember('P_givenLocMinVPost',vars)
P_givenLocMinVPost = Pbump(spikeCodes.localMinV_Post',probabilityParams.locMinVLR1,probabilityParams.locMinVLR2)';
spikeCodes = addToTable(spikeCodes,P_givenLocMinVPost,'P_givenLocMinVPost');
recomputeAll = 1;
end

if forceCompute || ~ismember('P_givenHeightToWidthRatio',vars)
P_givenHeightToWidthRatio = Pbump(spikeCodes.heightToWidthRatio',probabilityParams.heightToWidthRatioLR1,probabilityParams.heightToWidthRatioLR2)';
spikeCodes = addToTable(spikeCodes,P_givenHeightToWidthRatio,'P_givenHeightToWidthRatio');
recomputeAll = 1;
end

if recomputeAll
P_givenAll = spikeCodes.P_givenAmp .* spikeCodes.P_givenFR .*spikeCodes. P_givenConcurrent .* ...
    spikeCodes.P_givenLocMinIndPre .* spikeCodes.P_givenLocMinIndPost .* ...
    spikeCodes.P_givenLocMinVPre .* spikeCodes.P_givenLocMinVPost .* spikeCodes.P_givenHeightToWidthRatio;
spikeCodes = addToTable(spikeCodes,P_givenAll,'P_givenAll');
end

if ~exist('thresh','var') || isempty(rejectionThresh) || recomputeAll
[n, c] = histcounts(spikeCodes.P_givenAll);
N = cumsum(n); i = knee_pt(N,1:length(N),1);
if isnan(i)
    rejectionThresh = .98;
else
rejectionThresh = c(i);
end
% figure; plot(c,[N NaN]); hold on; plot(c(i),N(i),'o')
end

inds = spikeCodes.P_givenAll < rejectionThresh;
