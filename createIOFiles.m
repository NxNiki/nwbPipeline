function [inFiles, outFiles] = createIOFiles(channelOutFilePath, expOutFilePath, pattern)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

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
macroIdx = cellfun(@(x)~isempty(regexp(x, pattern, 'match', 'once')), channelFileNames(:, 1));
macroFileNames = channelFileNames(macroIdx, :);

writecell(macroFileNames, fullfile(channelOutFilePath, 'macroFileNames.csv'));

inFiles = macroFileNames(:, 2:end);
macroChannels = macroFileNames(:, 1);
numFilesEachChannel = size(inFiles, 2);
suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
outFiles = combineCellArrays(macroChannels, suffix);

emptyIdx = cellfun(@isempty, inFiles(:));

inFiles = inFiles(~emptyIdx);
outFiles = outFiles(~emptyIdx);

end