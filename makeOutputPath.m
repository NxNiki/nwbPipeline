function makeOutputPath(inputPath, outputPath, skipExist)

if ~exist(outputPath, "dir")
    mkdir(outputPath);
elseif ~skipExist  && ~strcmp(inputPath, outputPath)
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed in t1, t2 stops with 5 files processed, we cannot start
    % with the 6th file in t3 as we have 10 files saved.
    rmdir(outputPath, 's');
    mkdir(outputPath);
end