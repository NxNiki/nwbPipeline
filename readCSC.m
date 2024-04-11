function [signal, samplingInterval] = readCSC(filename)

matObj = matfile(filename);
signal = matObj.data;
signal = signal(:)';

if isa(matObj.samplingInterval, "duration")
    samplingInterval = seconds(matObj.samplingInterval);
else
    samplingInterval = matObj.samplingInterval;
end

end