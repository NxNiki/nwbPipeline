function [inFiles, outFiles] = createIOFiles(channelOutFilePath, expOutFilePath, pattern, renameChannels)
%createIOFiles create input/output file names to unpack.
%   A single recording may have multiple segments with different files. The
%   issue is the suffix of files for a single channel may not be correctly
%   ordered. So we create the output file with suffix correctly ordered.
%   The output file has a suffix with pattern '001.mat'. File name is the
%   same as the .ncs file.

if ~exist(channelOutFilePath, "dir")
    mkdir(channelOutFilePath);
end

if nargin < 4
    renameChannels = [];
end

channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
channelFileNames = channelFileNames(2:end,:);

% select macro/micro files and rename output file names so that alphabetic order 
% is consistent with temporal order. 
% For UCLA data, the macro files always start with 'R' or 'L' in the file 
% name. The micro files always start with 'G[A-D]'.
% For Iowa data, macro files have pattern: LFPx*.ncs
% micro files have pattern: PDes*.ncs
idx = cellfun(@(x)~isempty(regexp(x, pattern, 'match', 'once')), channelFileNames(:, 1));
inFileNames = channelFileNames(idx, :);

% reorder file names by numerical suffix:
formatString = @(str) regexprep(str, '(\d+)(?=\D*$)', '${sprintf(''%03d'', str2double($1))}');
formattedStrings = cellfun(formatString, inFileNames(:, 1), 'UniformOutput', false);
[~, sortOrder] = sort(formattedStrings);
inFileNames = inFileNames(sortOrder, :);

inFiles = inFileNames(:, 2:end);

if ~isempty(renameChannels)
    if length(renameChannels) ~= size(inFileNames, 1)
        error('renamed channels does not have equal length to original channels')
    end
    channels = renameChannels;
else
    channels = inFileNames(:, 1);
end
numFilesEachChannel = size(inFiles, 2);

suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
outFiles = combineCellArrays(channels, suffix);
outFiles = cellfun(@(fn) fullfile(channelOutFilePath, fn), outFiles, 'UniformOutput', false);

emptyIdx = cellfun(@isempty, inFiles(:));
outFiles(emptyIdx) = {''};

writecell(inFiles, fullfile(channelOutFilePath, 'inFileNames.csv'));
writecell(outFiles, fullfile(channelOutFilePath, 'outFileNames.csv'));

inFiles = inFiles(~emptyIdx);
outFiles = outFiles(~emptyIdx);

end