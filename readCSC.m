function [signal, samplingInterval] = readCSC(filename)
% samplingInterval will be converted to double type in seconds.

matObj = matfile(filename);
signal = matObj.data;
signal = signal(:)';

if isa(matObj.samplingInterval, "duration")
    samplingInterval = seconds(matObj.samplingInterval);
else
    samplingInterval = matObj.samplingInterval;
end

end