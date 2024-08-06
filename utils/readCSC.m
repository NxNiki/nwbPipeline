function [signal, samplingIntervalSeconds] = readCSC(filename)
% samplingInterval will be converted to double type in seconds.

matObj = matfile(filename, 'Writable', false);
signal = matObj.data;

if ismember('ADBitVolts', who('-file', filename)) && ~isnan(matObj.ADBitVolts)
    fprintf('reading neuralynx data with ADBitVolts: %f\n', matObj.ADBitVolts);
    signal = single(signal(:)) * matObj.ADBitVolts * 1e6; % convert signal to micro volt
elseif ismember('BlackRockUnits', who('-file', filename))
    fprintf('reading blackrock data with BlackRockUnits: %f\n', matObj.BlackRockUnits);
    signal = single(signal(:)) / matObj.BlackRockUnits; % black rock data is in 1/4 uV.
else
    message = 'ADBitVolts or BlackRockUnits not exists; your CSC data will not be scaled';
    warning(message);
end

if isa(matObj.samplingInterval, "duration")
    samplingIntervalSeconds = seconds(matObj.samplingInterval);
else
    samplingIntervalSeconds = matObj.samplingInterval;
end

end