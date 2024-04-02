function filenames = getFileNames(directory, fileExt, ignoreFilesWithSizeBelow)

if nargin < 3
    ignoreFilesWithSizeBelow = 16384;
end

d = dir([directory, filesep, '*', fileExt]);
d([d.isdir]) = [];
filenames = {d.name};

if nargin == 3
    filesizes = [d.bytes];
    filenames = filenames(filesizes > ignoreFilesWithSizeBelow + 1);  
end

filenames = filenames(:);
end