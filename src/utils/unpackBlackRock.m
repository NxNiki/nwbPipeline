function outFiles = unpackBlackRock(inFile, expFilePath, channelNames, skipExist)
% Reads analog samples BETWEEN t0 and t1.
% Actual time_stamps are returned in t


if nargin < 3
    channelNames = [];
end

if nargin < 4
    skipExist = [1, 1];
end

if length(skipExist) == 1
    skipExist = [skipExist, skipExist];
end

%% read header and create timestamps file:

tic
[~, electrodeInfoFile] = blackrock_read_header(inFile, expFilePath, skipExist(1));
toc

%% Read data by channel

tic
outFiles = blackrock_read_channel(inFile, electrodeInfoFile, skipExist(2), channelNames);
tic

writecell({inFile}, fullfile(fileparts(outFiles{1}), 'inFileNames.csv'));
writecell(outFiles, fullfile(fileparts(outFiles{1}), 'outFileNames.csv'));
