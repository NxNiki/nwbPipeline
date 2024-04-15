function makeOutputPath(inputPath, outputPath, skipExist)
% make outputPath if not exist.
% remove outputPath if exists and skipExist is false. Check inputPath in
% case inputPath and outputPath are same.

if iscell(inputPath)
    inputPath = unique(cellfun(@fileparts, inputPath, UniformOutput=false));
else
    inputPath = {fileparts(inputPath)};
end

if ~exist(outputPath, "dir")
    mkdir(outputPath);
elseif ~skipExist
    for i = 1:length(inputPath)
        if ~strcmp(inputPath{i}, outputPath)
            % create an empty dir to avoid not able to resume with unprocessed
            % files in the future if this job fails. e.g. if we have 10 files
            % processed in t1, t2 stops with 5 files processed, we cannot start
            % with the 6th file in t3 as we have 10 files saved.
            fprintf('skipExist not true, remove existing outputPath: %s\n', outputPath)
            rmdir(outputPath, 's');
            mkdir(outputPath);
        end
    end
end