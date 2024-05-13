function [cscFiles, timestampFiles, expNames] = readFilePath(expIds, filePath)
% load all csc File names in filePath.

cscFiles = [];
timestampFiles = [];
expNamesId = 1;

for i = 1: length(expIds)
    expId = expIds(i);
    cscFilePath = [filePath, sprintf('/Experiment%d', expId)];
    cscFilePath = fullfile(cscFilePath, 'CSC_micro');

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

