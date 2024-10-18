function saveTimestamps(timestamps, samplingInterval, timestampFile)
% timestamps should be in unix time
% samplingInterval: float in seconds

    num_samples = length(timestamps);
    timeend = (num_samples-1) * samplingInterval;

    [fpath, fname, ext] = fileparts(timestampFile);
    if ~strcmp(ext, '.mat')
        timestampFile = fullfile(fpath, [fname, '.mat']);
    end

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

        movefile(timestampFileTemp, timestampFile);

    catch err
        fprintf('error happened saving timestamp file: %s\n', timestampFile);
        disp(err)
    end

end
