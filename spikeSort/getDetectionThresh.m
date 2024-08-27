function [outputStruct, param] = getDetectionThresh(channelFiles, runRemovePLI)
% Does the first few steps of spike detection to find the threshold. This
% allows for using the same threshold across multiple sessions. Returns
% thr, as well as a struct with other variables created so that these steps
% can be skipped in spikeDetect if the struct is passed in.

    if nargin < 2
        runRemovePLI = false;
    end

    param = set_parameters();
    thr = nan(length(channelFiles), 1);
    noise_std_detect = nan(length(channelFiles), 1);
    noise_std_sorted = nan(length(channelFiles), 1);
    thrmax = nan(length(channelFiles), 1);

    for i = 1:length(channelFiles)
        if ~exist(channelFiles{i}, "file")
            warning("file not exist: %s", channelFiles{i})
            continue
        end
        [x, samplingInterval] = readCSC(channelFiles{i}, runRemovePLI);
        % assume same sampling interval across channels.
        fprintf("sampling frequency: %d\n", 1/samplingInterval)
        param.sr = 1/samplingInterval;

        [~, ~, noise_std_detect(i), noise_std_sorted(i), thr(i), thrmax(i)] = highPassFilter(x, param);
    end

    outputStruct.thrmax = max(thrmax);
    outputStruct.noise_std_detect = min(noise_std_detect);
    outputStruct.noise_std_sorted = min(noise_std_sorted);

    % it shouldn't go less than 18. If it does, it probably found a file 
    % with a long stretch of flat, and will then find millions of spikes in
    % the non-flat section.
    outputStruct.thr = max(min(thr), 18);
    
end