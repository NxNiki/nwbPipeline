function [inFiles, outFiles] = createIOFiles(channelOutFilePath, expOutFilePath, pattern, skipExist)
%createIOFiles create input/output file names to unpack.
%   A single recording may have multiple segments with different files. The
%   issue is the suffix of files for a single channel may not be correctly
%   ordered. So we create the output file with suffix correctly ordered.
%   The output file has a suffix with pattern '001.mat'. File name is the
%   same as the .ncs file.

if ~exist(channelOutFilePath, "dir")
    mkdir(channelOutFilePath);
elseif ~skipExist
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed in t1, t2 stops with 5 files processed, we cannot start
    % with the 6th file in t3 as we have 10 files saved.
    rmdir(channelOutFilePath, 's');
    mkdir(channelOutFilePath);
end

channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
channelFileNames = channelFileNames(2:end,:);

% select macro files and rename output file names so that alphabetic order 
% is consistent with temporal order. The macro files always start with 'R' 
% or 'L' in the file name
idx = cellfun(@(x)~isempty(regexp(x, pattern, 'match', 'once')), channelFileNames(:, 1));
inFileNames = channelFileNames(idx, :);

inFiles = inFileNames(:, 2:end);
channels = inFileNames(:, 1);
numFilesEachChannel = size(inFiles, 2);
suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
outFiles = combineCellArrays(channels, suffix);

emptyIdx = cellfun(@isempty, inFiles(:));
outFiles(emptyIdx) = {''};

writecell(inFiles, fullfile(channelOutFilePath, 'inFileNames.csv'));
writecell(outFiles, fullfile(channelOutFilePath, 'outFileNames.csv'));

inFiles = inFiles(~emptyIdx);
outFiles = outFiles(~emptyIdx);

end