function [timestamps, duration] = readTimestamps(filename)

useSinglePrecision = true;


tsFileObj = matfile(filename);
ts = tsFileObj.timeStamps;
timestamps = ts(:)';

if isa(tsFileObj.timeend, 'duration')
    duration = seconds(tsFileObj.timeend - tsFileObj.time0);
else
    duration = tsFileObj.timeend - tsFileObj.time0;
end


if useSinglePrecision
    timestamps = single(timestamps);
end

end