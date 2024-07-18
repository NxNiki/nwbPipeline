function [signal, samplingIntervalSeconds] = readCSC(filename)
% samplingInterval will be converted to double type in seconds.

matObj = matfile(filename, 'Writable', false);
signal = matObj.data;
signal = signal(:)';

if isa(matObj.samplingInterval, "duration")
    samplingIntervalSeconds = seconds(matObj.samplingInterval);
else
    samplingIntervalSeconds = matObj.samplingInterval;
end

end