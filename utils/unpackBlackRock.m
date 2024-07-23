function unpackBlackRock(inFile, expFilePath, channelNames, skipExist)

% Reads analog samples BETWEEN t0 and t1.
% Actual time_stamps are returned in t

if length(skipExist) == 1
    skipExist = [skipExist, skipExist];
end

tic
[timestampsFile, electrodeInfoFile] = blackrock_read_header(inFile, expFilePath, skipExist(1));

toc

%% Read data in in chunks and split by channel

tic
blackrock_read_channel(inFile, expFilePath, timestampsFile, electrodeInfoFile, skipExist(2))
tic
