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
    matObj = matfile(signalFiles{i}, 'r');
    signalCombined{i} = matObj.data;
    samplingInterval(i) = matObj.samplingInterval

    tsFileObj = matfile(timestampsFiles{i}, 'r');
    timestampsCombined{i} = tsFileObj.timeStamps;
end

samplingInterval = unqiue(samplingInterval);
if length(samplingInterval) > 1
    error('sampling Interval not match across files!');
end

signalGap = cell(numfiles, 1);
for i = 2: numFiles
    gapInterval = seconds(timestampsCombined{i}(end) - timestampsCombined{i-1}(1));
    if gapInterval / samplingInterval > GAP_THRESHOLD
        signalGap{i-1} = NaN(round(gapDuration/samplingInterval), 1);
    end
end

signalCombined = vercat(signalCombined, signalGap);
signal = [signalCombined{:}];

timestampsCombined = vercat(timestampsCombined, signalGap);
timestamps = [timestampsCombined{:}];


