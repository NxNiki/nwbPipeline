function [timestamps, duration] = readTimestamps(filename)

tsFileObj = matfile(filename);
ts = tsFileObj.timeStamps;
timestamps = ts(:)';

if isa(tsFileObj.timeend, 'duration')
    duration = seconds(tsFileObj.timeend - tsFileObj.time0);
else
    duration = tsFileObj.timeend - tsFileObj.time0;
end

end