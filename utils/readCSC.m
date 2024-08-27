function [signal, samplingIntervalSeconds] = readCSC(filename)
% samplingInterval will be converted to double type in seconds.

matObj = matfile(filename, 'Writable', false);
signal = matObj.data;

if ismember('ADBitVolts', who('-file', filename)) && ~isnan(matObj.ADBitVolts)
    signal = single(signal(:)) * matObj.ADBitVolts * 1e6; % convert signal to micro volt
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
        warning("scale samplingIntervalSeconds down by 1000")
        samplingIntervalSeconds = samplingIntervalSeconds/1000;
    end
end

end