function [signal, samplingIntervalSeconds] = readCSC(filename, runRemovePLI, clearRemovePLI)
% samplingInterval will be converted to double type in seconds.

if nargin < 2
    runRemovePLI = false;
end

if nargin < 3
    clearRemovePLI = false;
end

% do not raise error if fail to read mat file so that we keep process
% other channels.
try
    matObj = matfile(filename, 'Writable', false);
catch
    signal = [];
    samplingIntervalSeconds = [];
    warning('readCSC:error occurs reading file: %s', filename);
    return
end

signal = matObj.data;

if runRemovePLI && ismember('signalRemovePLI', who('-file', filename)) && ~isempty(matObj.signalRemovePLI)
    signal = matObj.signalRemovePLI;
    runRemovePLI = false;
elseif ismember('ADBitVolts', who('-file', filename)) && ~isnan(matObj.ADBitVolts)
    signal = single(signal(:)) * matObj.ADBitVolts * 1e6; % convert signal to micro volt
elseif ismember('BlackRockUnits', who('-file', filename))
    signal = single(signal(:)) * matObj.BlackRockUnits;
else
    message = 'ADBitVolts is NaN; your CSC data will not be scaled';
    warning(message);
    % logMessage(logFile, message);
end

if isa(matObj.samplingInterval, "duration")
    samplingIntervalSeconds = seconds(matObj.samplingInterval);
else
    samplingIntervalSeconds = matObj.samplingInterval;

    % check units of sampling intervals:
    while 1/samplingIntervalSeconds < 500
        warning("scale samplingInterval down from: %d to %d.", samplingIntervalSeconds, samplingIntervalSeconds/1000)
        samplingIntervalSeconds = samplingIntervalSeconds/1000;
    end
end

if clearRemovePLI
    matObj.signalRemovePLI = [];
end

if runRemovePLI
    fprintf("run removePLI on: %s\n", filename);
    tic
    signalRemovePLI = removePLI(double(signal), 1/samplingIntervalSeconds, numel(60:60:3060), [50 .2 1], [.1 4 1], 2, 60);
    toc
    signalRemovePLI = single(signalRemovePLI);
    matObj = matfile(filename, 'Writable', true);
    if ~clearRemovePLI
        matObj.signalRemovePLI = signalRemovePLI;
    end
    signal = signalRemovePLI;
end


