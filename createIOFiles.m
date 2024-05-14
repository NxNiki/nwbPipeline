function [inFiles, outFiles] = createIOFiles(channelOutFilePath, expOutFilePath, pattern)
%createIOFiles create input/output file names to unpack.
%   A single recording may have multiple segments with different files. The
%   issue is the suffix of files for a single channel may not be correctly
%   ordered. So we create the output file with suffix correctly ordered.
%   The output file has a suffix with pattern '001.mat'. File name is the
%   same as the .ncs file.

if ~exist(channelOutFilePath, "dir")
    mkdir(channelOutFilePath);
end

channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
channelFileNames = channelFileNames(2:end,:);

% select macro/micro files and rename output file names so that alphabetic order 
% is consistent with temporal order. The macro files always start with 'R' 
% or 'L' in the file name. The micro files always start with 'G[A-D]'.
idx = cellfun(@(x)~isempty(regexp(x, pattern, 'match', 'once')), channelFileNames(:, 1));
inFileNames = channelFileNames(idx, :);

inFiles = inFileNames(:, 2:end);
channels = inFileNames(:, 1);
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