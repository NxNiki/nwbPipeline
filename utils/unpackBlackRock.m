function unpackBlackRock(inFile, expFilePath, channelNames, skipExist)
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
[~, electrodeInfoFile] = blackrock_read_header(inFile, expFilePath, [], skipExist(1));
toc

%% Read data in in chunks and split by channel

tic
tempOutFiles = blackrock_read_channel(inFile, expFilePath, electrodeInfoFile, skipExist(2));

if length(channelNames) == length(tempOutFiles)
    for i = 1: length(tempOutFiles)
        path = fileparts(tempOutFiles{i});
        movefile(tempOutFiles{i}, fullfile(path, channelNames{i}));
    end
end
tic
