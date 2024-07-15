function [signalInterpolate, spikeIntervalPercentage, interpolateIndex, spikeIndex] =  interpolateSpikes(signal, signalTimestamps, spikes, spikeTimestamps)

peakMissMatchWarnning = 0;

interpolateRangePre = milliseconds(1);
interpolateRangePost = milliseconds(1.5);
samplingRate = 32000;

interpolateRangePre = round(interpolateRangePre / (seconds(1)/samplingRate));
interpolateRangePost = round(interpolateRangePost / (seconds(1)/samplingRate));

if max(signalTimestamps) < max(spikeTimestamps)
    warning("spikes extending signal are removed! Check spikes file match with micro CSC file!")
    spikeTimestamps = spikeTimestamps(spikeTimestamps<=max(signalTimestamps));
end

spikeIntervalPercentage = 0;
spikeIndexInSignal = interp1(signalTimestamps, 1:length(signalTimestamps), spikeTimestamps, 'nearest');
interpolateIndex = false(1, length(signal));
spikeIndex = false(1, length(signal));
spikeIndex(spikeIndexInSignal) = true;

for i = 1:length(spikeIndexInSignal)

    % extract unit spike and corresponding signal:
    [~, unitPeakIdx] = max(abs(spikes(i,:) - median(spikes(i,:))));
    spikeInSignalIdxStart = spikeIndexInSignal(i) - unitPeakIdx + 1;
    spikeInSignal = signal(spikeInSignalIdxStart: spikeInSignalIdxStart + length(spikes(i,:)) - 1);
    [~, signalPeakIdx] = max(abs(spikeInSignal - median(spikeInSignal)));

    if signalPeakIdx ~= unitPeakIdx && peakMissMatchWarnning
        warning('miss match of peak index in unit: %d and signals: %d, index: %d', unitPeakIdx, signalPeakIdx, i)
    end
    
    % on noisy data, the raw signal can be monotonic, then the peak index
    % will be at the edge of the spike interval.
    peakShift = signalPeakIdx - unitPeakIdx;
    if abs(peakShift) > 20
        peakShift = 0;
    end

    spikeInSignalIdxPeak = spikeIndexInSignal(i) + peakShift;
    interpolateIndex(spikeInSignalIdxPeak - interpolateRangePre: spikeInSignalIdxPeak + interpolateRangePost) = true;
    spikeIntervalPercentage = spikeIntervalPercentage + 1 + interpolateRangePre + interpolateRangePost;

end

signalInterpolate = signal;
signalInterpolate(interpolateIndex) = NaN;

% while nnz(isnan(signalInterpolate)) > 0
%     signalInterpolate = fillmissing(signalInterpolate, "movmean", round((1 + interpolateRangePre + interpolateRangePost) * 1.2));
% end
signalInterpolate = fillmissing(signalInterpolate, "linear", 'SamplePoints', signalTimestamps);

spikeIntervalPercentage = spikeIntervalPercentage/length(signal);

end


