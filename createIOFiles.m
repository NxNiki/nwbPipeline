function [inFiles, outFiles] = createIOFiles(channelOutFilePath, expOutFilePath, pattern)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

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