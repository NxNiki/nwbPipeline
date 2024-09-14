function outFiles = blackrock_read_channel(inFile, electrodeInfoFile, skipExist, channelNames)
% Function to read Blackrock channel data.
% Blackrock data is saved in a single file containing all channels. We use
% openNSx.m to read each channel for the .ns3/.ns5/.ns6 file and save data
% separately.
% when using channelNames to rename the file, make sure its order is
% matches data in .NSx file correctly. If some channels are skipped, fill
% the channelNames with empty strings. The best practice would be to have
% the channels named correctly in the .NSx header.


if nargin < 3 || isempty(skipExist)
    skipExist = 0;
end

if nargin < 4 || isempty(channelNames)
    channelNames = [];
end

outputFilePath = fileparts(electrodeInfoFile);
electrodeInfoObj = matfile(electrodeInfoFile);
NSx = electrodeInfoObj.NSx;
channelId = NSx.MetaTags.ChannelID;
channelIdx = channelId <= 256;

if ~isempty(channelNames)
    outFiles = cellfun(@(x)fullfile(outputFilePath, [x, '.mat']), channelNames, 'UniformOutput', false);
else
    % trailing null characters (ASCII code 0) are often used in C-style strings
    % to indicate the end of the string but can be problematic in MATLAB.
    outFiles = cellfun(@(x)fullfile(outputFilePath, [x(double(x) ~= 0), '.mat']), {NSx.ElectrodesInfo(channelIdx).Label}, 'UniformOutput', false);
end

nchan = length(outFiles);
pattern = 'G[A-D][1-4]-(.*?)[1-9]';

for i = 1: nchan
    if skipExist && exist(outFiles{i}, 'file')
        fprintf('skip existing file: %s\n', outFiles{i});
        continue
    end

    [~, outFile] = fileparts(outFiles{i});
    if isempty(outFile)
        continue
    end

    % skip micro channel with empty channel name:
    match = regexp(outFile, pattern, 'tokens', 'once');

    if ~isempty(match)
        if isempty(match{1}) || strcmp(match{1}, '''''') || strcmp(match{1}, '''') || strcmp(match{1}, ' ') || strcmp(match{1}, '""') || strcmp(match{1}, '" "')
            warning('skip empty channel: %s', outFiles{i});
            continue
        end
    end

    fprintf('writing data to: %s\n', outFiles{i});
    NSx = openNSx('report','read', inFile, 'channels', i, 'precision', 'int16');

    data = NSx.Data;
    samplingInterval = seconds(1) / NSx.MetaTags.SamplingFreq;

    tmpOutFile = strrep(outFiles{i}, '.mat', 'tmp.mat');
    if exist(tmpOutFile, 'file')
        delete(tmpOutFile)
    end
    outFileObj = matfile(tmpOutFile);
    outFileObj.data = data;
    outFileObj.samplingInterval = samplingInterval;
    outFileObj.samplingIntervalSeconds = seconds(samplingInterval);
    outFileObj.BlackRockUnits = 1/4;
    movefile(tmpOutFile, outFiles{i});
end

fprintf('Done.\n');

end
