function [tsFileName, electrodeInfoFileName] = blackrock_read_header(inFile, expFilePath, skipExist)
% read header from black rock file and save timestamps and electrode
% information.


    if nargin < 3 || isempty(skipExist)
        skipExist = 1;

    end

    NSx = openNSx(inFile, 'noread');

    if NSx.MetaTags.SamplingFreq > 29999
        outputFilePath = fullfile(expFilePath, 'CSC_micro');
    else
        outputFilePath = fullfile(expFilePath, 'CSC_macro');
    end

    tsFileName = fullfile(outputFilePath, 'lfpTimeStamps_001.mat');
    electrodeInfoFileName = fullfile(outputFilePath, 'electrode_info.mat');

    if skipExist && exist(tsFileName, "file") && exist(electrodeInfoFileName, "file")
        return
    end

    % save timestamps:
    samplingInterval = seconds(1) / NSx.MetaTags.SamplingFreq;
    samplingIntervalSeconds = seconds(samplingInterval);
    timeStamps = colonByLength(NSx.MetaTags.startTime, samplingIntervalSeconds, NSx.MetaTags.DataPoints);

    time0 = 0; 
    timeendSeconds = timeStamps(end);
    timeend = seconds(timeStamps(end));

    if ~exist(outputFilePath, "dir")
        mkdir(outputFilePath)
    end
    
    save(tsFileName, 'timeStamps', 'time0', 'timeendSeconds', 'timeend', 'samplingInterval', 'samplingIntervalSeconds', '-v7.3');
    
    % save electrode_info:
    % save general info about the electrodes and recording times:
    save(electrodeInfoFileName, 'NSx');

end

