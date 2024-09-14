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

    % save filenames for micro files to csv as there may be multiple segments in a single experiment.
    % files for a single channel will be in the same row.
    microFilesExp = readcell(fullfile(cscFilePath, 'outFileNames.csv'), Delimiter=",");
    microFilesExp = cellfun(@(x)replacePath(x, cscFilePath), microFilesExp, UniformOutput=false);
    cscFiles = [cscFiles, microFilesExp];

    timestampFilesExp = dir(fullfile(cscFilePath, 'lfpTimeStamps*.mat'));
    timestampFiles = [timestampFiles, fullfile(cscFilePath, {timestampFilesExp.name})];

    expNames(expNamesId: length(timestampFiles)) = {sprintf('Exp%d', expIds(i))};
    expNamesId = length(timestampFiles) + 1;
end
