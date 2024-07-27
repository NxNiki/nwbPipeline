function filenames = getNeuralynxFiles(directory, fileExt, ignoreFilesWithSizeBelow)
% list the .ncs/.nev files in neuralynx data. Files will be ignore if the name
% matches pattern defined in IGNORE_FILES in config.m.

if nargin < 3 || isempty(ignoreFilesWithSizeBelow)
    ignoreFilesWithSizeBelow = 16384;
end

% load configure variables:
run('config.m')
% IGNORE_FILES

d = dir([directory, filesep, '*', fileExt]);
d([d.isdir]) = [];
filenames = {d.name};

if nargin == 3
    filesizes = [d.bytes];
    filenames = filenames(filesizes > ignoreFilesWithSizeBelow + 1);  
end

filenames = filenames(:);

keep = cellfun(@(x) ~any(cellfun(@(p) ~isempty(regexp(x, p, 'once')), IGNORE_FILES)), filenames);
filenames = filenames(keep);

if isempty(filenames)
    error(strcat("No Neuralynx files detected in folder: %s\n",
            "Make sure the directory you selected has .ncs files",
            " or change IGNORE_FILES in config.m"), directory);
end

end