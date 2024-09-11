function baseDir = getBaseDir()

% Get the full path of the current script or function
currentFilePath = mfilename('fullpath');

% Extract the base directory from the full path
[baseDir, ~, ~] = fileparts(fileparts(currentFilePath));

end
