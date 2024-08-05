function [signal, samplingIntervalSeconds] = readCSC(filename, runRemovePLI)
% samplingInterval will be converted to double type in seconds.

if nargin < 2
    runRemovePLI = false;
end

matObj = matfile(filename, 'Writable', false);
signal = matObj.data;

if runRemovePLI && ismember('signalRemovePLI', who('-file', filename))
    signal = matObj.signalRemovePLI;
    runRemovePLI = false;
elseif ismember('ADBitVolts', who('-file', filename)) && ~isnan(matObj.ADBitVolts)
    signal = single(signal(:)) * matObj.ADBitVolts * 1e6; % convert signal to micro volt
elseif ismember('BlackRockUnits', who('-file', filename))
    signal = single(signal(:)) / matObj.BlackRockUnits; % black rock data is in 1/4 uV.
else
    message = 'ADBitVolts or BlackRockUnits not exists; your CSC data will not be scaled';
    warning(message);
    % logMessage(logFile, message);
end

if isa(matObj.samplingInterval, "duration")
    samplingIntervalSeconds = seconds(matObj.samplingInterval);
else
    samplingIntervalSeconds = matObj.samplingInterval;

    % check units of sampling intervals:
    while 1/samplingIntervalSeconds < 500
        warning("scale samplingIntervalSeconds down by 1000")
        samplingIntervalSeconds = samplingIntervalSeconds/1000;
    end
end

if runRemovePLI
    fprintf("run removePLI on: %s\n", filename);
    signalRemovePLI = removePLI(double(signal), 1/samplingIntervalSeconds, numel(60:60:3060), [50 .2 1], [.1 4 1], 2, 60);
    signalRemovePLI = single(signalRemovePLI);
    matObj = matfile(filename, 'Writable', true);
    matObj.signalRemovePLI = signalRemovePLI;
    signal = signalRemovePLI;
end

end