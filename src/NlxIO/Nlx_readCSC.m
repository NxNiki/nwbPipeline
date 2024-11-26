function [signal, ADBitVolts, samplingInterval, channelNumber] = Nlx_readCSC(fileName, logPath)

% SYNTAX: [data,timeStamps,samplingInterval,chNum] = Nlx_readCSC(fileName, computeTS)
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
% Xin isolated read timestamps to Nlx_readTimeStamps.m


if ~exist('logPath','var') || isempty(logPath)
    logPath = '';
end

if ~exist(fileName, "file")
    error("file not exist: %s", fileName);
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

[timestamps, channelNumber, sampleFrequency, numSamples, signal, header] = Nlx2MatCSC_v3(fileName, FieldSelection, ExtractHeader, ExtractMode, ModeArray);

signal = removeOutlierBlocks(signal, timestamps);

incompleteBlocks = find(numSamples ~= size(signal,1));
for i = 1:length(incompleteBlocks)
    signal(numSamples(incompleteBlocks(i))+1:end, incompleteBlocks(i)) = NaN;
end

[~, fname] = fileparts(fileName);
logFile = fullfile(logPath, 'unpack_log-Nlx_readCSC', [fname, '.log']);
% logMessage(logFile, sprintf('read csc from: %s.', fileName));

if length(unique(sampleFrequency))~=1
    message = [fname, ': Sampling Frequency is not uniform across data set, please proceed with caution...'];
    logMessage(logFile, message);
end
if length(unique(channelNumber))~=1
    message = [fname, ': More than one channel found. This code is not equipped for that...'];
    logMessage(logFile, message);
end
if any(numSamples(1:end-1) < 512)
    message = sprintf('%s: blocks with missing samples: ', fname, find(numSamples(1:end-1) < 512));
    % logMessage(logFile, message);
end

% converts to nSamples per millisecond to be consistent with how we store
% data for Black Rock
sampleFrequency = sampleFrequency(1) * 1e-3; 

InputInverted = 1;
if isempty(header)
    % log this.
    ADBitVolts = NaN;
    message = [fname, ': Empty header info.'];
    logMessage(logFile, message);
else
    findADBitVolts = cellfun(@(x)~isempty(regexp(x, 'ADBitVolts', 'once')), header);
    ADBitVolts = regexp(header{findADBitVolts},'(?<=ADBitVolts\s)[\d\.e\-]+', 'match');
    if isempty(ADBitVolts)
        ADBitVolts = NaN;
        message = [fname, ': Cannot extract header info: ADBitVolts'];
        logMessage(logFile, message);
    else
        ADBitVolts = str2double(ADBitVolts{1});
    end

    findInputInverted = cellfun(@(x)~isempty(regexp(x, 'InputInverted', 'once')), header);
    InputInvertedText = regexp(header{findInputInverted}, '(?<=InputInverted\s)[a-zA-Z]+', 'match');

    if isempty(InputInvertedText)
        message = [fname, ': Cannot extract header info: InputInverted'];
        logMessage(logFile, message);
    elseif strcmpi(InputInvertedText{1}, 'true') || strcmpi(InputInvertedText{1}, 'True')
        InputInverted = -1;
    else
        % this gives error when running in parfor...
        % message = [fname, ': InputInverted not true'];
        % logMessage(logFile, message);
    end
end

signal = reshape(signal, [], 1);
% we remove missing data here, will fill missing data with -inf based on
% reference timestamps and signal timestamps later. Will also fill shorter
% or longer blocks with -inf. see fillMssingData.m
signal(isnan(signal)) = [];
signal = int16(signal * InputInverted);

samplingInterval = milliseconds(1/sampleFrequency);

