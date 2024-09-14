function saveTimestamps(timestamps, samplingInterval, timestampFile)
% timestamps should be in unix time
% samplingInterval: float in seconds

    num_samples = length(timestamps);
    timeend = (num_samples-1) * samplingInterval;

    matobj = matfile(timestampFile, Writable=true);
    matobj.timeStamps = timestamps;
    matobj.samplingInterval = samplingInterval;
    matobj.samplingIntervalSeconds = seconds(samplingInterval);
    matobj.time0 = 0;
    matobj.timeend = timeend;
    matobj.timeendSeconds = seconds(timeend);

end
