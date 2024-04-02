function [signal, computedTimeStamps, samplingInterval, channelNumber] = Nlx_readCSC(fileName,computeTS)

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

if ~exist('computeTS','var')||isempty(computeTS)
    computeTS = 1;
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
    signal(numSamples(incompleteBlocks(i))+1:end,incompleteBlocks(i)) = NaN;
end

% TO DO: log this info to run it on cluster:
if length(unique(sampleFrequency))~=1
    warning('Sampling Frequency is not uniform across data set, please proceed with caution...')
end
if length(unique(channelNumber))~=1
    warning('You appear to be reading data from more than one channel. This code is not equipped for that...')
end

sampleFrequency = sampleFrequency(1)*1e-3; % converts to nSamples per millisecond to be consistent with how we store data for Black Rock

if isempty(header)
    ADBitVolts = NaN;
else
    findADBitVolts = cellfun(@(x)~isempty(regexp(x,'ADBitVolts', 'once')),header);
    ADBitVolts = regexp(header{findADBitVolts},'(?<=ADBitVolts\s)[\d\.e\-]+','match');
    if isempty(ADBitVolts)
        ADBitVolts = NaN;
    else
        ADBitVolts = str2double(ADBitVolts{1});
    end
end

signal = reshape(signal,[],1);
signal(isnan(signal)) = [];

if ~isnan(ADBitVolts)
    signal = -signal*ADBitVolts*1e6;
else
    warning('ADBitVolts is NaN; your CSC data will not be scaled')
end

timeStamps = timeStamps * 1e-6; % ts now in seconds
samplingInterval = 1/sampleFrequency; % not in seconds, but gets multiplied by 1e-3 later

if computeTS
    totalSamples = cumsum(numSamples);
    computedTimeStamps = zeros(1,totalSamples(end));

    for t = 1:length(timeStamps)
        if t==1
            startSample = 1;
        else
            startSample = totalSamples(t-1) + 1;
        end
        endSample = startSample + numSamples(t)-1;
        startTS = timeStamps(t);
        theseTS = (1:numSamples(t)) * samplingInterval * 1e-3 + startTS;
        computedTimeStamps(startSample:endSample) = theseTS;
    end
else
    computedTimeStamps = NaN;
end
