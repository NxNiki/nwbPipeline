function [signal, computedTimeStamps, samplingInterval, channelNumber] = Nlx_readCSC(fileName, computeTS, logPath)

% SYNTAX: [data,timeStamps,samplingInterval,chNum] = Nlx_readCSC(fileName,computeTS)
%
% if computeTS is false,timeStamps will be returned as NaN; this can save a
% lot of computational time if you're processing lots of files that all
% have the same timestamps.
%
% This function deals with the fact that Nlx writes its data into columns
% of a matrix, but that in certain circumstances a column will not get
% filled all the way, and in that case, the remaining data in that column
% will be a duplicate of the data from the previous column. This causes
% issues with both the data itself and the timestamps if you just assume
% that the columns are of equal length.
%
% Please note that samplingInterval is in milliseconds, so an interval of
% 0.5 corresponds to an actual sampling rate of 2000 Hz.
%
% Code written by Emily Mankin and distributed under Creative Commons
% Attribution license, which means you can share, but you can't remove the
% attribution. Code is offered without warranty, but tries hard to be
% correct.

% Xin added log warning message
% Xin added check InputInverted in header.
% Xin simplified algorithm to computeTS.
% Xin change samplingInterval to matlab duration.


if ~exist('computeTS','var') || isempty(computeTS)
    computeTS = 1;
end

if ~exist('logPath','var') || isempty(logPath)
    logPath = '';
end

% 1. Timestamps   
% 2. Sc Numbers
% 3. Cell Numbers
% 4. Params
% 5. Data Points
FieldSelection(1) = 1;
FieldSelection(2) = 1;
FieldSelection(3) = 1;
FieldSelection(4) = 1;
FieldSelection(5) = 1;

ExtractHeader = 1;
ExtractMode = 1;
ModeArray=[]; %all.

[timeStamps, channelNumber, sampleFrequency, numSamples, signal, header] = Nlx2MatCSC_v3(fileName, FieldSelection, ExtractHeader, ExtractMode, ModeArray);

incompleteBlocks = find(numSamples ~= size(signal,1));
for i = 1:length(incompleteBlocks)
    signal(numSamples(incompleteBlocks(i))+1:end, incompleteBlocks(i)) = NaN;
end

[~, fname] = fileparts(fileName);
logFile = fullfile(logPath, [fname, '.log']);

if length(unique(sampleFrequency))~=1
    message = 'Sampling Frequency is not uniform across data set, please proceed with caution...';
    logMessage(logFile, message);
end
if length(unique(channelNumber))~=1
    message = 'You appear to be reading data from more than one channel. This code is not equipped for that...';
    logMessage(logFile, message);
end

sampleFrequency = sampleFrequency(1) * 1e-3; % converts to nSamples per millisecond to be consistent with how we store data for Black Rock

if isempty(header)
    % log this.
    ADBitVolts = NaN;
    InputInverted = -1;
    message = 'Empty header info.';
    logMessage(logFile, message);
else
    findADBitVolts = cellfun(@(x)~isempty(regexp(x, 'ADBitVolts', 'once')), header);
    ADBitVolts = regexp(header{findADBitVolts},'(?<=ADBitVolts\s)[\d\.e\-]+', 'match');
    if isempty(ADBitVolts)
        ADBitVolts = NaN;
        message = 'Cannot extract header info: ADBitVolts';
        logMessage(logFile, message);
    else
        ADBitVolts = str2double(ADBitVolts{1});
    end

    findInputInverted = cellfun(@(x)~isempty(regexp(x, 'InputInverted', 'once')), header);
    InputInverted = regexp(header{findInputInverted}, '(?<=InputInverted\s)[a-zA-Z]+', 'match');

    if isempty(InputInverted)
        message = 'Cannot extract header info: InputInverted';
        logMessage(logFile, message);
        InputInverted = 1;
    elseif strcmpi(InputInverted{1}, 'false')
        InputInverted = 1;
    elseif strcmpi(InputInverted{1}, 'true')
        InputInverted = -1;
    else
        message = 'Unrecognized header info: InputInverted';
        logMessage(logFile, message);
    end
end

signal = reshape(signal,[],1);
signal(isnan(signal)) = [];

if ~isnan(ADBitVolts)
    signal = InputInverted * signal * ADBitVolts * 1e6; % convert signal to micro volt (need to confirm)
else
    message = 'ADBitVolts is NaN; your CSC data will not be scaled';
    logMessage(logFile, message);
end

timeStamps = timeStamps * 1e-6; % ts now in seconds
samplingInterval = milliseconds(1/sampleFrequency); 

if computeTS
    sampleIdx = cumsum([1; numSamples(:)]);
    computedTimeStamps = zeros(1, sampleIdx(end) - 1);

    for i = 1:length(timeStamps)
        startSample = sampleIdx(i);
        endSample = sampleIdx(i+1)-1;
        startTS = timeStamps(i);
        theseTS = (1:numSamples(i)) * seconds(samplingInterval) + startTS;
        computedTimeStamps(startSample: endSample) = theseTS;
    end
else
    computedTimeStamps = NaN;
end


