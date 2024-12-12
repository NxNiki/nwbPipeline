function [cscFiles, timestampFiles] = readCSCFilePath(cscFilePath)

    % save filenames for micro files to csv as there may be multiple segments in a single experiment.
    % files for a single channel will be in the same row.
    cscFiles = readcell(fullfile(cscFilePath, 'outFileNames.csv'), Delimiter=",");
    cscFiles = cellfun(@(x)replacePath(x, cscFilePath), cscFiles, UniformOutput=false);

    timestampFilesExp = dir(fullfile(cscFilePath, 'lfpTimeStamps*.mat'));
    timestampFiles = fullfile(cscFilePath, {timestampFilesExp.name});

end