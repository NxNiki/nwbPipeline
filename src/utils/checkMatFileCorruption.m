function isCorrupted = checkMatFileCorruption(filePath)
    % CHECKMATFILECORRUPTION checks if a .mat file is corrupted.
    % Input:
    %   filePath: Path to the .mat file
    % Output:
    %   isCorrupted: Boolean value. True if the file is corrupted, false otherwise.

    isCorrupted = false;  % Assume the file is not corrupted initially

    % Check if the file exists
    if ~isfile(filePath)
        fprintf('Error: %s does not exist.\n', filePath);
        isCorrupted = true;
        return;
    end

    try
        % Try to check the file contents without loading
        fileInfo = whos('-file', filePath);
        
        % If whos returns empty, the file is unreadable or corrupted
        if isempty(fileInfo)
            fprintf('Error: %s is not a valid .mat file or it is corrupted.\n', filePath);
            isCorrupted = true;
            return;
        end
        
        % Try loading a small portion of the data to ensure the file is readable
        load(filePath, fileInfo(1).name);  % Try loading the first variable as a test
        fprintf('%s is valid and readable.\n', filePath);
        
    catch ME
        % If an error occurs, assume the file is corrupted
        fprintf('Error: Unable to load the file. %s\n', ME.message);
        isCorrupted = true;
    end
end
