function [clusterCharacteristics, sr] = calculateClusterCharacteristics(spikeFolder, CSCFolder, trials, imageDir, checkResponse)
%CALCULATECLUSTERCHARACTERISTICS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    imageDir = [];
end

if nargin < 5
    checkResponse = false;
end

maxlocalMaxima = 5;
maxLocalMaximaRatio = .5;
maxLateRangeRatio = 1;
maxMeanStandardErr = 2;
maxNoiseProminence = 2;
maxWaveformsToInclude = 2500;

trialStimId = cell2mat({trials.imageID});
stimOnsetTime = [trials.stimulusOnsetTime];
responseOnsetTime = [trials.respondedAtTime];

% get the start time of experiment and sampling rate. The start time will
% be subtracted from stimulus onset time. (both unix time in seconds)
[timestamps, ~, samplingIntervalSeconds] = readTimestamps(fullfile(CSCFolder, 'lfpTimeStamps_001.mat'));
sr = 1 / samplingIntervalSeconds;

stimOnsetTime = checkTimestamps(stimOnsetTime, timestamps(1), 1e3);
responseOnsetTime = checkTimestamps(responseOnsetTime, timestamps(1), 1e3);

dataLength = numel(timestamps)/sr;
clear timestamps

if isfield(trials, 'patient')
    info.patient_num = trials(1).patient;
end
clear trials

[imageNames, imageId] = getStimInfo(imageDir, '.jpg');
[audioNames, audioId] = getStimInfo(imageDir, '.aiff');
[videoNames, videoId] = getStimInfo(imageDir, '.mp4');
imageNames = [imageNames(:); audioNames(:)];
imageId = [imageId(:); audioId(:)];

clusterFiles = dir(fullfile(spikeFolder, 'times_*.mat'));

if isempty(clusterFiles)
    error('no cluster files detected, run spike sorting before this step!');
end

if ~((2e4 <= sr) && (sr <= 4e4))
    warning('invalid sampling frequency: %f', sr);
else
    fprintf('calculateClusterCharacteristics: sampling frequency: %d\n', sr);
end

clusterCharacteristics = [];

for i = 1:length(clusterFiles)
    fprintf('process: %s\n', clusterFiles(i).name);
    info.csc_num = i;
    if info.csc_num == 129
        continue
    end
    clusterFileObj = matfile(fullfile(spikeFolder, clusterFiles(i).name));
    cluster_class = clusterFileObj.cluster_class;
    
    % read spike waveforms:
    rejectedSpikes = clusterFileObj.spikeIdxRejected;
    spikeFileName = strrep(strrep(clusterFiles(i).name, 'times_', ''), '.mat', '_spikes.mat');
    spikeFileObj = matfile(fullfile(spikeFolder, spikeFileName));
    spikes = spikeFileObj.spikes;
    spikes(rejectedSpikes, :) = [];

    % regular expression with lookbehind and lookahead
    pattern = '(?<=times_)G[A-D][1-4]-\w+(?=.mat)';
    info.cluster_region = extractChannelName(clusterFiles(i).name, pattern);

    clusterNums = unique(cluster_class(:, 1));
    for j = 1:length(clusterNums)
        info.cluster_num = clusterNums(j);

        allWaveforms = spikes(cluster_class(:, 1) == clusterNums(j), :);
        allSpikeTimes = cluster_class(cluster_class(:, 1) == clusterNums(j), 2);
        ISI = diff(allSpikeTimes);
        info.allTimes = allSpikeTimes;
        info.noiseProminence = max([ ...
            2*sum(ISI>.0156&ISI<0.0176)/max(sum(ISI>.0116&ISI<.0156), ...
            sum(ISI>.0176&ISI<.0216)), ...
            2*sum(ISI>.0323&ISI<0.0343)/max(sum(ISI>.0283&ISI<.0323), ...
            sum(ISI>.0343&ISI<.0383)), ...
            2*sum(ISI>.009&ISI<0.011)/max(sum(ISI>.005&ISI<.009), ...
            sum(ISI>.011&ISI<.015)) ...
            ]);
        info.firingRate = size(allWaveforms, 1)/dataLength;
        info.refPeriodViolations = sum(ISI < .003)/size(allWaveforms, 1);
        info.meanAmplitude = mean(allWaveforms(:, 23));
        meanWaveform = mean(allWaveforms, 1);

        [pks, locs] = findpeaks(meanWaveform);
        info.localMaxima = numel(pks);
        minPkSeparation = round(.3*1e-3*sr);

        try
            [pksLim, locsLim] = findpeaks(meanWaveform, 'MinPeakDistance', minPkSeparation);

            pksLim = sort(pksLim, 'descend');
            if numel(pksLim) <2
                info.localMaximaRatio = 0;
            else
                info.localMaximaRatio = pksLim(2)/pksLim(1);
            end
        catch err
            warning('error occurs in calculate localMaximaRatio: %s\nset it to 0', err)
            info.localMaximaRatio = 0;
        end

        info.lateRangeRatio = range(meanWaveform(round(numel(meanWaveform)/2):end)) / max(meanWaveform);
        info.meanStandardErr = mean( std(allWaveforms, 0, 1) / sqrt(size(allWaveforms, 1)));
        info.rejectCluster = info.localMaximaRatio > maxLocalMaximaRatio || ...
            info.lateRangeRatio > maxLateRangeRatio || info.meanStandardErr > maxMeanStandardErr|| info.noiseProminence > maxNoiseProminence; %info.localMaxima > maxlocalMaxima
        nWaveforms = min(maxWaveformsToInclude, size(allWaveforms, 1));
        info.allWaveforms = allWaveforms(randperm(size(allWaveforms, 1), nWaveforms), :);
        info.meanWaveform = {meanWaveform};

        [~, minLocation] = min(meanWaveform(23:end));
        [~, maxLocation] = max(meanWaveform(23:end));
        if meanWaveform(23) > 0
            info.waveDuration = 1000*(minLocation - 1)/sr;
        else
            info.waveDuration = 1000*(maxLocation - 1)/sr;
        end
        
        [info.stim, info.numSelective, info.selectivity] = getScreeningInfo(stimOnsetTime, trialStimId, allSpikeTimes, imageNames, imageId, (0:100:1000), (50:100:950));
        
        if ~isempty(videoNames)
            [info.video, info.videoNumSelective, info.videoSelectivity] = getScreeningInfo(stimOnsetTime, trialStimId, allSpikeTimes, videoNames, videoId, (0:1000:10000), (500:1000:9500));
        end

        if checkResponse
            [info.response, info.responseNumSelective, info.responseSelectivity] = getScreeningInfo(responseOnsetTime, trialStimId, allSpikeTimes, imageNames, imageId, (0:100:1000), (50:1000:950), [-1000, 0, 500]);
        end

        clusterCharacteristics = [clusterCharacteristics; struct2table(info, 'AsArray', 1)];
    end
end

clusterCharacteristics = sortrows(clusterCharacteristics, 1);

end

function [screeningInfo, numSelective, selectivity] = getScreeningInfo(stim_onsets, allStimId, allSpikeTimes, stimNames, stimId, binEdges1, binEdges2, latencyWindow)

log10_thresh = 3;

if nargin < 8
    latencyWindow = [-500, 0, 1000];
end

screeningInfo = struct;
numStimuli = length(stimNames);

[ baselineLatencies, ~ ] = getSpikeLatencies(stim_onsets, allSpikeTimes*1e3, [latencyWindow(1), latencyWindow(2)]);
[ stimLatencies, ~ ] = getSpikeLatencies(stim_onsets, allSpikeTimes*1e3, [latencyWindow(2), latencyWindow(3)]);
[ allLatencies, ~ ] = getSpikeLatencies(stim_onsets, allSpikeTimes*1e3, [-1000 10000]);

if latencyWindow(3) - latencyWindow(2) > latencyWindow(2) - latencyWindow(1)
    testDirection = 'left';
else
    testDirection = 'right';
end

baselineToStimRatio = 500/mode(diff(binEdges1));
baselineDistribution = cellfun(@numel, baselineLatencies);

spikesToAllImages1 = cell2mat(cellfun(@(x)histcounts(x, binEdges1), stimLatencies, 'UniformOutput', 0)');
spikesToAllImages2 = cell2mat(cellfun(@(x)histcounts(x, binEdges2), stimLatencies, 'UniformOutput', 0)');
allFR = zeros(1, numStimuli);
allScores = zeros(1, numStimuli);

for k = 1:numStimuli
    relevantTrials = allStimId==stimId(k);

    stimSpikes = median(sum(spikesToAllImages1(relevantTrials, :), 2));
    allFR(k) = stimSpikes;
    screeningInfo(k).spikes = allLatencies(relevantTrials);
    screeningInfo(k).stimName = stimNames{k};
    screeningInfo(k).stimId = stimId(k);

    if stimSpikes < 3
        screeningInfo(k).score = 0;
        allScores(k) = 0;
        continue;
    end

    pr = zeros(1, 19);
    for h = 1:2:19
        pr(h) = ranksum(baselineDistribution, baselineToStimRatio*spikesToAllImages1(relevantTrials, ceil(h/2)), 'tail', testDirection);
    end
    for h = 2:2:18
        pr(h) = ranksum(baselineDistribution, baselineToStimRatio*spikesToAllImages2(relevantTrials, h/2), 'tail', testDirection);
    end
    [~, ~, ~, pr] = fdr_bh(pr); % why use fdr when we select the max score?
    scoreTrace = -log10(pr);
    screeningInfo(k).score = max(scoreTrace);
    allScores(k) = max(scoreTrace);
    screeningInfo(k).responseOnset = find(scoreTrace > log10_thresh, 1) * mode(diff(binEdges1))/2;
end

screeningInfo = {screeningInfo};
numSelective = sum(allScores > log10_thresh);
FRThresh = linspace(0, max(allFR), 1000);
scoreVals = arrayfun(@(x)sum(allFR > x), FRThresh)/numStimuli;
selectivity = 1-2*mean(scoreVals);

end

function timestamps = checkTimestamps(timestamps, time0, factor)
% check start time of timestamps and subtract experiment start time.
% factor is used to convert seconds to milliseconds (if 1e3).
% caution: factor unix time may lead to overflow of large numbers. so
% subtract time0 before factor.

if timestamps(1) > time0
    timestamps = (timestamps - time0) * factor;
else
    timestamps = timestamps * factor;
end

end
