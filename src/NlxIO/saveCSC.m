function saveCSC(signal, ADBitVolts, samplingInterval, outFileName)

    num_samples = length(signal);
    timeend = (num_samples-1) * samplingInterval;

    [fpath, fname, ext] = fileparts(outFileName);
    if ~strcmp(ext, '.mat')
        outFileName = fullfile(fpath, [fname, '.mat']);
    end

    outFileNameTemp = strrep(outFileName, '.mat', '_temp.mat');
    if exist(outFileNameTemp, "file")
        warning('delete temp file: %s\n', outFileNameTemp);
        delete(outFileNameTemp)
    end

    try
        matobj = matfile(outFileNameTemp, 'Writable', true);
        matobj.samplingInterval = samplingInterval;
        matobj.samplingIntervalSeconds = seconds(samplingInterval);
        matobj.data = signal;
        matobj.time0 = 0;
        matobj.timeend = timeend;
        matobj.timeendSeconds = seconds(timeend);
        matobj.ADBitVolts = ADBitVolts;
        movefile(outFileNameTemp, outFileName);
    catch err
        fprintf('error happened saving csc file: %s\n', outFileName);
        disp(err)
    end

end