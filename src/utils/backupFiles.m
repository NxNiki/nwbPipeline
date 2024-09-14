function backupFiles(sourceFiles, backupPath, removeSource)


if nargin < 3
    removeSource = true;
end

sourceFiles = sourceFiles(:);
filesBackup = cellfun(@(x)strrep(x, filePath, backupPath), sourceFiles, UniformOutput=false);

parfor i = 1: length(filesBackup)
    moveFile(sourceFiles{i}, filesBackup{i}, removeSource);
end

end

function moveFile(source, dest, removeSource)
    % Extract the directory part from the destination path
    [destDir, ~, ~] = fileparts(dest);
    [sourceDir, ~, ~] = fileparts(source);

    % Check if the directory exists, and create it if it does not
    if ~exist(destDir, 'dir')
        mkdir(destDir);
    end

    % also copy IO record so that we can rerun analysis directly from LTS:
    IOLogFileOut = fullfile(destDir, 'outFileNames.csv');
    IOLogFileIn = fullfile(sourceDir, 'outFileNames.csv');

    if ~exist(IOLogFileOut, "file") && exist(IOLogFileIn, "file")
        IOLogIn = readcell(IOLogFileIn);
        IOLogOut = cellfun(@(x)strrep(x, sourceDir, destDir), IOLogIn);
        writecell(IOLogOut, IOLogFileOut);
    end

    % Move the file
    if exist(source, "file")
        fprintf('move file: %s \nto: %s\n', source, dest);

        % Copy the file to the destination
        copyStatus = copyfile(source, dest, 'f');

        if copyStatus && removeSource
            % Get information about the source and destination files
            sourceInfo = dir(source);
            destInfo = dir(dest);

            % Check if the destination file exists and is not corrupted
            if exist(dest, 'file') && sourceInfo.bytes == destInfo.bytes
                delete(source);
            else
                warning('dest file corrpted, try to backup again!');
                delete(dest);
            end
        else
            warning('File copy operation failed.');
        end
    end
end
