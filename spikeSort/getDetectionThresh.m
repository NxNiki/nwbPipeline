function [outputStruct, param, maxAmp] = getDetectionThresh(channelFiles)
% Does the first few steps of spike detection to find the threshold. This
% allows for using the same threshold across multiple sessions. Returns
% thr, as well as a struct with other variables created so that these steps
% can be skipped in spikeDetect if the struct is passed in.

    param = set_parameters();
    maxAmp = 500;
    thr = nan(length(channelFiles), 1);
    noise_std_detect = nan(length(channelFiles), 1);
    noise_std_sorted = nan(length(channelFiles), 1);
    thrmax = nan(length(channelFiles), 1);

    for i = 1:length(channelFiles)
        [x, samplingInterval] = readCSC(channelFiles{i});
        param.sr = 1/samplingInterval;
        param.ref = floor(1.5 * param.sr/1000);

        sr = param.sr;
        stdmin = param.stdmin;
        stdmax = param.stdmax;
        fmin_detect = param.detect_fmin;
        fmax_detect = param.detect_fmax;
        fmin_sort = param.sort_fmin;
        fmax_sort = param.sort_fmax;

        %HIGH-PASS FILTER OF THE DATA
        if exist('ellip','file')                  % Checks for the signal processing toolbox
            [b_detect,a_detect] = ellip(param.detect_order, 0.1, 40, [fmin_detect fmax_detect]*2/sr);
            [b,a] = ellip(param.sort_order, 0.1, 40, [fmin_sort fmax_sort]*2/sr);
            xf_detect = filtfilt(b_detect, a_detect, x);
            xf = filtfilt(b, a, x);
        else
            xf = fix_filter(x);                   % bandpass filtering between [300 3000] without the toolbox.
            xf_detect = xf;
        end

        noise_std_detect(i) = median(abs(xf_detect))/0.6745;
        noise_std_sorted(i) = median(abs(xf))/0.6745;
        thr(i) = stdmin * noise_std_detect(i);        %thr for detection is based on detect settings.
        thrmax(i) = min(maxAmp, stdmax * noise_std_sorted(i));     %thrmax for artifact removal is based on sorted settings.

    end

    outputStruct.thrmax = max(thrmax);
    outputStruct.noise_std_detect = min(noise_std_detect);
    outputStruct.noise_std_sorted = min(noise_std_sorted);

    % it shouldn't go less than 18. If it does, it probably found a file 
    % with a long stretch of flat, and will then find millions of spikes in
    % the non-flat section.
    outputStruct.thr = max(min(thr), 18);
end