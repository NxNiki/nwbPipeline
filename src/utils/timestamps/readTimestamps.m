function [timestamps, duration, samplingIntervalSeconds] = readTimestamps(filename)
% the timestamps file has different version with samplingInterval may or
% may not exist, and it can be a duration object or a float (in seconds).
% this function will always return it as float in seconds and NaN if it
% does not exist. sampling can also be saved in raw unpacked files (see
% readCSC.m, I know this is bad design...)


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
