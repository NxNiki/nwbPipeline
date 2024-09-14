function [clusterCharacteristics] = calculateClusterCharacteristics(spikeFolder, CSCFolder, trials, imageDir)
%CALCULATECLUSTERCHARACTERISTICS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    imageDir = [];
end

log10_thresh = 3;

maxlocalMaxima = 5;
maxLocalMaximaRatio = .5;
maxLateRangeRatio = 1;
maxMeanStandardErr = 2;
maxNoiseProminence = 2;
maxWaveformsToInclude = 2500;

imageNames = unique({trials.trialTag});
if ~isempty(imageDir)
    allVideoDir = dir(fullfile(imageDir, '*.mp4'));
    allVideoTrialTags = regexp({allVideoDir.name}, '.*?(?=_id)', 'match', 'once');
    [videoNames, videoIdxes] = intersect(imageNames, allVideoTrialTags);
    imageNames(videoIdxes) = [];
end

clusterFiles = dir(fullfile(spikeFolder, 'times_*.mat'));

if isempty(clusterFiles)
    error('no cluster files detected, run spike sorting before this step!');
end

[timestamps, ~, samplingIntervalSeconds] = readTimestamps(fullfile(CSCFolder, 'lfpTimeStamps_001.mat'));

sr = 1 / samplingIntervalSeconds;
dataLength = numel(timestamps)/sr;
time0 = timestamps(1);

clusterCharacteristics = [];

if isfield(trials, 'patient')
    info.patient_num = trials(1).patient;
end

for i = 1:length(clusterFiles)
    info.csc_num = i;
    if info.csc_num == 129
        continue
    end
    clusterFileObj = matfile(fullfile(spikeFolder, clusterFiles(i).name));
    cluster_class = clusterFileObj.cluster_class;

    if ismember('spikes', who(clusterFileObj))
        spikes = clusterFileObj.spikes;
        cluster_class(:, 2) = cluster_class(:, 2) / 1000;
    else
        rejectedSpikes = clusterFileObj.spikeIdxRejected;
        spikeFileName = strrep(strrep(clusterFiles(i).name, 'times_', ''), '.mat', '_spikes.mat');
        spikeFileObj = matfile(fullfile(spikeFolder, spikeFileName));
        spikes = spikeFileObj.spikes;
        spikes(rejectedSpikes, :) = [];
    end

    % regular expression with lookbehind and lookahead
    pattern = '(?<=times_)G[A-D][1-4]-\w+(?=.mat)';
    info.cluster_region = extractChannelName(clusterFiles(i).name, pattern);

    clusterNums = unique(cluster_class(:, 1));
    for j = 1:length(clusterNums)
        info.cluster_num = clusterNums(j);

        allWaveforms = spikes(cluster_class(:, 1) == clusterNums(j), :);
        allTimes = cluster_class(cluster_class(:, 1) == clusterNums(j), 2);
        ISI = diff(allTimes);
        info.allTimes = allTimes;
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
        [pksLim, locsLim] = findpeaks(meanWaveform, 'MinPeakDistance', minPkSeparation);
        pksLim = sort(pksLim, 'descend');
        if numel(pksLim) <2
            info.localMaximaRatio = 0;
        else
            info.localMaximaRatio = pksLim(2)/pksLim(1);
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

        [info.screeningInfo, info.numSelective, info.selectivity] = getScreeningInfo(trials, time0, allTimes, log10_thresh, imageNames, (0:100:1000), (50:100:950));
        if ~isempty(videoNames)
            [info.videoScreeningInfo, info.videoNumSelective, info.videoSelectivity] = getScreeningInfo(trials, time0, allTimes, log10_thresh, videoNames, (0:1000:10000), (500:1000:9500));
        end
        clusterCharacteristics = [clusterCharacteristics; struct2table(info, 'AsArray', 1)];
    end
end

clusterCharacteristics = sortrows(clusterCharacteristics, 1);

outFileObj = matfile(fullfile(spikeFolder, 'clusterCharacteristics.mat'), "Writable", true);
outFileObj.clusterCharacteristics = clusterCharacteristics;
outFileObj.samplingRate = sr;

end

function [screeningInfo, numSelective, selectivity] = getScreeningInfo(trials, time0, allTimes, log10_thresh, imageNames, binEdges1, binEdges2)

screeningInfo = struct;
numStimuli = length(imageNames);

if trials(1).stimulusOnsetTime > time0
    stim_onsets = 1e3*([trials.stimulusOnsetTime] - time0);
else
    stim_onsets = 1e3*([trials.stimulusOnsetTime]);
end

[ baselineLatencies, ~ ] = getSpikeLatencies( stim_onsets, allTimes*1e3, [-500 0]);
[ stimLatencies, ~ ] = getSpikeLatencies( stim_onsets, allTimes*1e3, [0 1000]);
[ allLatencies, ~ ] = getSpikeLatencies( stim_onsets, allTimes*1e3, [-1000 10000]);

baselineToStimRatio = 500/mode(diff(binEdges1));
baselineDistribution = cellfun(@numel, baselineLatencies);

spikesToAllImages1 = cell2mat(cellfun(@(x)histcounts(x, binEdges1), stimLatencies, 'UniformOutput', 0)');
spikesToAllImages2 = cell2mat(cellfun(@(x)histcounts(x, binEdges2), stimLatencies, 'UniformOutput', 0)');
allFR = zeros(1, numStimuli);
allScores = zeros(1, numStimuli);
for k = 1:numStimuli
    screeningInfo(k).imageName = imageNames{k};
    relevantTrials = find(strcmp({trials.trialTag}, imageNames{k}));
    stimSpikes = median(sum(spikesToAllImages1(relevantTrials, :), 2));

    allFR(k) = stimSpikes;
    screeningInfo(k).spikes = allLatencies(relevantTrials);
    screeningInfo(k).name = imageNames{k};

    if stimSpikes < 3
        screeningInfo(k).score = 0;
        allScores(k) = 0;
        continue;
    end

    pr = zeros(1, 19);
    for h = 1:2:19
        pr(h) = ranksum(baselineDistribution, baselineToStimRatio*spikesToAllImages1(relevantTrials, ceil(h/2)), 'tail', 'left');
    end
    for h = 2:2:18
        pr(h) = ranksum(baselineDistribution, baselineToStimRatio*spikesToAllImages2(relevantTrials, h/2), 'tail', 'left');
    end
    [~, ~, ~, pr] = fdr_bh(pr);
    scoreTrace = -log10(pr);
    screeningInfo(k).score = max(scoreTrace);
    allScores(k) = max(scoreTrace);
    screeningInfo(k).responseOnset = find(scoreTrace > log10_thresh, 1)*mode(diff(binEdges1))/2;
end

screeningInfo = {screeningInfo};
numSelective = sum(allScores > log10_thresh);
FRThresh = linspace(0, max(allFR), 1000);
scoreVals = arrayfun(@(x)sum(allFR > x), FRThresh)/numStimuli;
selectivity = 1-2*mean(scoreVals);

end
