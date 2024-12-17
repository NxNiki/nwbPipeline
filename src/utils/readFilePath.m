function [cscFiles, timestampFiles, expNames] = readFilePath(expIds, filePath, channel)
% load all csc File names in filePath.

if nargin < 3
    channel = 'micro';
end

cscFiles = [];
timestampFiles = [];
expNamesId = 1;

for i = 1: length(expIds)
    expId = expIds(i);
    cscFilePath = [filePath, sprintf('/Experiment-%d', expId)];
    if strcmp(channel, 'micro')
        cscFilePath = fullfile(cscFilePath, 'CSC_micro');
    elseif strcmp(channel, 'macro')
        cscFilePath = fullfile(cscFilePath, 'CSC_macro');
    else
        error('undefined channel type. select "micro" or "macro"');
    end

    [cscFile, timestampsFile] = readCSCFilePath(cscFilePath);
    cscFiles = [cscFiles, cscFile];
    timestampsFiles = [timestampsFiles, timestampsFile];

    expNames(expNamesId: length(timestampFiles)) = {sprintf('Exp%d', expIds(i))};
    expNamesId = length(timestampFiles) + 1;
end
