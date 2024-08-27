function [timestamps, duration, samplingIntervalSeconds] = readTimestamps(filename)

tsFileObj = matfile(filename, 'Writable', false);
ts = tsFileObj.timeStamps;
timestamps = ts(:)';

if isa(tsFileObj.timeend, 'duration')
    duration = seconds(tsFileObj.timeend - tsFileObj.time0);
else
    duration = tsFileObj.timeend - tsFileObj.time0;
end

if ~ismember("samplingInterval", who(tsFileObj))
    samplingIntervalSeconds = NaN;
elseif isa(tsFileObj.samplingInterval, "duration")
    samplingIntervalSeconds = seconds(tsFileObj.samplingInterval);
else
    samplingIntervalSeconds = tsFileObj.samplingInterval;
end

end