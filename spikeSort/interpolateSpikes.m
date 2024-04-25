function [signalInterpolate, spikeIntervalPercentage] =  interpolateSpikes(signal, signalTimestamps, spikes, spikeTimestamps)

peakMissMatchWarnning = 0;

interpolateRangePre = milliseconds(1);
interpolateRangePost = milliseconds(1.5);
samplingRate = 32000;

interpolateRangePre = round(interpolateRangePre / (seconds(1)/samplingRate));
interpolateRangePost = round(interpolateRangePost / (seconds(1)/samplingRate));

spikeIntervalPercentage = 0;
spikeIndexInSignal = interp1(signalTimestamps, 1:length(signalTimestamps), spikeTimestamps, 'nearest');
signalInterpolate = signal;

for i = 1:length(spikeIndexInSignal)

    % extract unit spike and corresponding signal:
    [~, unitPeakIdx] = max(abs(spikes(i,:) - median(spikes(i,:))));
    spikeInSignalIdxStart = spikeIndexInSignal(i) - unitPeakIdx + 1;
    spikeInSignal = signal(spikeInSignalIdxStart: spikeInSignalIdxStart + length(spikes(i,:)) - 1);
    [~, signalPeakIdx] = max(abs(spikeInSignal - median(spikeInSignal)));

    if signalPeakIdx ~= unitPeakIdx && peakMissMatchWarnning
        warning('miss match of peak index in unit: %d and signals: %d, index: %d', unitPeakIdx, signalPeakIdx, i)
    end

    % ----------------- uncomment and set break point to compare signals with spikes:
    % spikeInSignal = signal(spikeInSignalIdxStart: spikeInSignalIdxStart + length(unitSpikes(t,:)) - 1);
    % plot([unitSpikes(t,:)', spikeInSignal(:) - mean(spikeInSignal), unitAvgSpike(:)])
    % legend({'unitSpike', 'spikeInSignal', 'unitAvgSpike'})
    % -----------------

    spikeInSignalIdxPeak = spikeIndexInSignal(i) + signalPeakIdx - unitPeakIdx;
    signalInterpolate(spikeInSignalIdxPeak - interpolateRangePre: spikeInSignalIdxPeak + interpolateRangePost) = NaN;
    spikeIntervalPercentage = spikeIntervalPercentage + 1 + interpolateRangePre + interpolateRangePost;

end

signalInterpolate = fillmissing(signalInterpolate, "movmean", round((1 + interpolateRangePre + interpolateRangePost) * 1.2));
signalInterpolate = fillmissing(signalInterpolate, "nearest");
spikeIntervalPercentage = spikeIntervalPercentage/length(signal);