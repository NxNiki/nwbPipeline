function [signal ,timestamps, samplingInterval] = combineCSC(signalFiles, timestampsFiles, maxGapDuration)
%combineCSC Combine CSC signals. filling gaps with NaNs if gap between
%segments larger than threshold.

% signalFiles: cell(n, 1)
% timestampFiles: cell(n, 1)


if nargin < 3
    maxGapDuration = seconds(1000);
end

GAP_THRESHOLD = 2;

numFiles = length(signalFiles);

if numFiles ~= length(timestampsFiles)
    error('signalFiles and timeStampFiles should have same length!');
end

signalCombined = cell(1, numFiles);
timestampsCombined = cell(1, numFiles);
samplingInterval = zeros(numFiles, 1);

parfor i = 1: numFiles
    fprintf('reading csc (order %d): \n%s \n', i, signalFiles{i});

    [signalCombined{i}, samplingInterval(i)] = readCSC(signalFiles{i})
    [timestampsCombined{i}, ~] = readTimestamps(timestampsFiles{i})
end

samplingInterval = unique(samplingInterval);
if length(samplingInterval) > 1
    error('sampling Interval not match across files!');
end

samplingInterval = seconds(samplingInterval);
timestampsCombinedNext = timestampsCombined(2:end);
signalGap = cell(1, numFiles);
timestampsGap = cell(1, numFiles);

parfor i = 2: numFiles
    gapInterval = min(seconds(timestampsCombinedNext{i-1}(1) - timestampsCombined{i-1}(end)), maxGapDuration);
    if gapInterval / samplingInterval > GAP_THRESHOLD
        gapLength = floor(gapInterval/samplingInterval);
        signalGap{i-1} = NaN(1, gapLength);
        timestampsGap{i-1} = (timestampsCombined{i-1}(end) + samplingInterval) + 0: 1/samplingInterval: 1/samplingInterval * (gapLength - 1);
    end
end

signalCombined = [signalCombined(:)', signalGap(:)'];
signal = [signalCombined{:}];

timestampsCombined = [timestampsCombined(:)', timestampsGap(:)'];
timestamps = [timestampsCombined{:}];


