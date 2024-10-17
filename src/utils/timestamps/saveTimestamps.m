function saveTimestamps(timestamps, samplingInterval, timestampFile)
% timestamps should be in unix time
% samplingInterval: float in seconds

    num_samples = length(timestamps);
    timeend = (num_samples-1) * samplingInterval;

    timestampFileTemp = strrep(timestampFile, '.mat', '_temp.mat');
    if exist(timestampFileTemp, "file")
        delete(timestampFileTemp)
    end

    try
        matobj = matfile(timestampFileTemp, Writable=true);
        matobj.timeStamps = timestamps;
        matobj.samplingInterval = samplingInterval;
        matobj.samplingIntervalSeconds = seconds(samplingInterval);
        matobj.time0 = 0;
        matobj.timeend = timeend;
        matobj.timeendSeconds = seconds(timeend);

    catch err
        fprintf('error happened saving timestamp file: %s\n', timestampFile);
        disp(err)
    end

    movefile(timestampFileTemp, timestampFile);

end
