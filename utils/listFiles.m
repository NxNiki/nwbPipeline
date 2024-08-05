function files = listFiles(filePath, includePattern, excludePattern)
% files will be returned with fullpath.

    if nargin < 2
        includePattern = '*';
    end

    files = dir(fullfile(filePath, includePattern));
    files = fullfile(filePath, {files.name});
    
    if nargin == 3 && ~isempty(excludePattern)
        files = removeFiles(files, excludePattern);
    end

end
