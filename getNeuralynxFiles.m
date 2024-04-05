function filenames = getNeuralynxFiles(directory, fileExt, ignoreFilesWithSizeBelow)

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

end