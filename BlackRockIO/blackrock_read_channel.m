function outFiles = blackrock_read_channel(inFile, electrodeInfoFile, skipExist)
% Function to read Blackrock channel data using code adapted from neuroport2mat_all2.m (PDM).
% Blackrock data is saved in a single file containing all channels, and
% individual channels cannot be read separately. This function splits the
% data into multiple chunks and then merges these chunks for each channel.


if nargin < 3 || isempty(skipExist)
    skipExist = 0;
end

outputFilePath = fileparts(electrodeInfoFile);
electrodeInfoObj = matfile(electrodeInfoFile);
NSx = electrodeInfoObj.NSx;
channelId = NSx.MetaTags.ChannelID;
channelId = channelId(channelId <= 128);
nchan = length(channelId);

% trailing null characters (ASCII code 0) are often used in C-style strings 
% to indicate the end of the string but can be problematic in MATLAB.
outFiles = cellfun(@(x)fullfile(outputFilePath, [x(double(x) ~= 0), '.mat']), {NSx.ElectrodesInfo(:).Label}, 'UniformOutput', false);

parfor i = 1: nchan
    if skipExist && exist(outFiles{i}, 'file') 
        continue
    end
    fprintf('writing data to: %s\n', outFiles{i});
    NSx = openNSx('report','read', inFile, 'channels', channelId(i), 'uV', 'precision', 'double');

    data = NSx.Data;
    samplingInterval = seconds(1) / NSx.MetaTags.SamplingFreq;

    outFileObj = matfile(outFiles{i});
    outFileObj.data = data;
    outFileObj.samplingInterval = samplingInterval;
end

fprintf('Done.\n');

end