function [signal ,timestamps, samplingInterval] = combineCSC(signalFiles, timestampsFiles, gapDuration)
%combineCSC Summary of this function goes here
%   timestamps 

if nargin < 3
    gapDuration = seconds(1);
end

GAP_THRESHOLD = 1.2;

numFiles = length(signalFiles);

if numFiles ~= length(timestampsFiles)
    error('signalFiles and timeStampFiles should have same length!');
end

signalCombined = cell(1, numFiles);
timestampsCombined = cell(1, numFiles);
samplingInterval = zeros(numFiles, 1);

parfor i = 1: numFiles
    matObj = matfile(signalFiles{i});
    signal = matObj.data;
    signalCombined{i} = signal(:)';
    samplingInterval(i) = seconds(matObj.samplingInterval);

    tsFileObj = matfile(timestampsFiles{i});
    ts = tsFileObj.timeStamps;
    timestampsCombined{i} = ts(:)';
end

samplingInterval = unique(samplingInterval);
if length(samplingInterval) > 1
    error('sampling Interval not match across files!');
end

samplingInterval = seconds(samplingInterval);

signalGap = cell(1, numFiles);
parfor i = 2: numFiles
    gapInterval = seconds(timestampsCombined{i}(end) - timestampsCombined{i-1}(1));
    if gapInterval / samplingInterval > GAP_THRESHOLD
        signalGap{i-1} = NaN(1, round(gapDuration/samplingInterval));
    end
end

signalCombined = [signalCombined(:)', signalGap(:)'];
signal = [signalCombined{:}];

timestampsCombined = [timestampsCombined(:)', signalGap(:)'];
timestamps = [timestampsCombined{:}];


