function [signal, timestamps, samplingIntervalDuration, timestampsStart] = combineCSC(signalFiles, timestampsFiles, maxGapDuration, useSinglePrecision)
% combineCSC: Combine CSC signals. filling gaps with NaNs if gap between
% segments larger than threshold. Set signalFiles empty to only process
% timestampsFiles.

% signalFiles: cell(n, 1)
% timestampFiles: cell(n, 1). Timestamps file cannot be empty as we need it
%   to fill the gaps between experiments/segments.
% maxGapDuration: the max duration of gaps filled between experiments or
%   segments caused by experiment pause.

if nargin < 3 || isempty(maxGapDuration)
    % maxGapDuration = milliseconds(2);
    maxGapDuration = inf;
end

if nargin < 4
    useSinglePrecision = true;
end

GAP_THRESHOLD = 2;

processSignal = true;
if isempty(timestampsFiles)
    error('combineCSC: timeStampFiles cannot be empty!');
elseif isempty(signalFiles)
    processSignal = false;
    warning('combineCSC: no signal files');
elseif length(timestampsFiles) ~= length(signalFiles)
    error('combineCSC: length of timesstampsFiles and signalFiles not match!')
end

numFiles = max(length(signalFiles), length(timestampsFiles));

signalCombined = cell(1, numFiles);
timestampsCombined = cell(1, numFiles);
samplingInterval = nan(numFiles, 1);

for i = 1: numFiles
    [timestampsCombined{i}, ~, samplingInterval(i)] = readTimestamps(timestampsFiles{i});
    if ~processSignal
        continue
    elseif exist(signalFiles{i}, "file")
        fprintf('reading csc (order %d): \n%s \n', i, signalFiles{i});
        [signalCombined{i}, samplingIntervalCSC] = readCSC(signalFiles{i});
        if isnan(samplingInterval(i))
            % samplingInterval may not exist in older version of timestamps
            % file and will return as NaN:
            samplingInterval(i) = samplingIntervalCSC;
        end
    else
        warning("CSC file not exist: \n%s.\n Data will be filled with NaNs\n", signalFiles{i});
        signalCombined{i} = nan(numel(timestampsCombined{i}), 1);
    end
end

% check if timestamps and signals have same length:
timestampLength = cellfun("length", timestampsCombined);
signalLength = cellfun("length", signalCombined);

if any(signalLength ~= 0 ) && any(timestampLength ~= signalLength)
    error(["missmatched length of signal and timestamps: \n", sprintf('%s \n', signalFiles{timestampLength ~= signalLength})])
end

samplingInterval = unique(samplingInterval(~isnan(samplingInterval)));
if length(samplingInterval) > 1
    error('sampling Interval not match across files!');
end

samplingIntervalDuration = seconds(samplingInterval);
timestampsCombinedNext = timestampsCombined(2:end);
signalGap = cell(1, numFiles);
timestampsGap = cell(1, numFiles);
% fill gaps between experiments/segments with NaNs:
for i = 2: numFiles
    gapInterval = min(seconds(timestampsCombinedNext{i-1}(1) - timestampsCombined{i-1}(end)), maxGapDuration);
    if gapInterval / samplingIntervalDuration > GAP_THRESHOLD
        gapLength = floor(gapInterval/samplingIntervalDuration);
        signalGap{i-1} = NaN(gapLength, 1);
        timestampsGap{i-1} = (timestampsCombined{i-1}(end) + samplingInterval) + (0: samplingInterval: samplingInterval * (gapLength - 1));
    end
end

timestampsCombined = [timestampsCombined(:), timestampsGap(:)]';
timestamps = [timestampsCombined{:}];

if processSignal
    signalCombined = [signalCombined(:), signalGap(:)]';
    signal = vertcat(signalCombined{:});
else
    signal = [];
end

if isempty(timestamps)
    timestampsStart = [];
    return
end

% large number lose precision so we save relative timestamps so that we can
% use single precision.
timestampsStart = timestamps(1);
timestamps = timestamps - timestamps(1);

if useSinglePrecision
    timestampsSingle = single(timestamps);
    if ~any(diff(timestampsSingle)==0)
        timestamps = timestampsSingle;
    end
    signal = single(signal);
end
