% move intermediate results to LTS
clear

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));

expIds = (3:11);
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

backupPath = '/Volumes/DATA/HoffmanBackup/MovieParadigm/570_MovieParadigm';

[microFiles, timestampFiles] = readFilePath(expIds, filePath);

microFilesBackup = cellfun(@(x)strrep(x, filePath, backupPath), microFiles, UniformOutput=false);
timestampFilesBackup = cellfun(@(x)strrep(x, filePath, backupPath), timestampFiles, UniformOutput=false);

cellfun(@(x, y) moveFile(x, y), microFiles, microFilesBackup);
cellfun(@(x, y) moveFile(x, y), timestampFiles, timestampFilesBackup);


function moveFile(source, dest)
    % Extract the directory part from the destination path
    [destDir, ~, ~] = fileparts(dest);

    % Check if the directory exists, and create it if it does not
    if ~exist(destDir, 'dir')
        mkdir(destDir);
    end

    % Move the file
    if exist(source, "file")
        fprintf('move file: %s \nto: %s\n', source, dest);

        % Copy the file to the destination
        copyStatus = copyfile(source, dest, 'f');
        
        if copyStatus
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






