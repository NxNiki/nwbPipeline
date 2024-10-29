function [computedTimeStamps, samplingInterval, largeGap] = computeTimeStamps(timeStamps, numSamples, sampleFrequency)
% timeStamps, numSamples are returned by Nlx2MatCSC_v3. 
% timeStamps: the start timestamps of each block (512 samples)
% numSamples: number of samples in each block (usually 512 except for the
% last block).
% sampleFrequency: Hz.

sampleFrequency = sampleFrequency(1) * 1e-3; % converts to nSamples per millisecond to be consistent with how we store data for Black Rock
samplingInterval = milliseconds(1/sampleFrequency);

% check if timeStamps has large gaps:
timeStampsDiff = diff(timeStamps);
largeGap = false;
if max(timeStampsDiff) > 2 * median(timeStampsDiff)
    largeGap = true;
end

sampleIdx = cumsum([1; numSamples(:)]);
computedTimeStamps = nan(1, sampleIdx(end) - 1);

for i = 1:length(timeStamps)
    startSample = sampleIdx(i);
    endSample = sampleIdx(i+1)-1;
    startTS = timeStamps(i);
    theseTS = ((1:numSamples(i))-1) * seconds(samplingInterval) + startTS;
    computedTimeStamps(startSample: endSample) = theseTS;
end
