function [thr_all, outputStruct, param, maxAmp] = getDetectionThresh(channelFiles)
% Does the first few steps of spike detection to find the threshold. This
% allows for using the same threshold across multiple sessions. Returns
% thr, as well as a struct with other variables created so that these steps
% can be skipped in spikeDetect if the struct is passed in.

    param = set_parameters();
    maxAmp = 500;
    thr = zeros(length(channelFiles), 1);

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
            [b_detect,a_detect] = ellip(param.detect_order,0.1,40,[fmin_detect fmax_detect]*2/sr);
            [b,a] = ellip(param.sort_order,0.1,40,[fmin_sort fmax_sort]*2/sr);
            xf_detect = filtfilt(b_detect, a_detect, x);
            xf = filtfilt(b, a, x);
        else
            xf = fix_filter(x);                   % bandpass filtering between [300 3000] without the toolbox.
            xf_detect = xf;
        end

        noise_std_detect = median(abs(xf_detect))/0.6745;
        noise_std_sorted = median(abs(xf));
        thr(i) = stdmin * noise_std_detect;        %thr for detection is based on detect settings.
        thrmax = min(maxAmp, stdmax * noise_std_sorted);     %thrmax for artifact removal is based on sorted settings.

        outputStruct(i).xf = xf;
        outputStruct(i).xf_detect = xf_detect;
        outputStruct(i).noise_std_detect = noise_std_detect;
        outputStruct(i).noise_std_sorted = noise_std_sorted;
        outputStruct(i).thr = thr;
        outputStruct(i).thrmax = thrmax;

    end

    thr_all = min(thr);
    % it shouldn't go less than 18. If it does, it probably found a file with a long stretch of flat, and will then find millions of spikes in the non-flat section.
    thr_all = max(thr_all, 18);

    maxThr = max([outputStruct.thrmax]);
    common_noise_std_detect = min([outputStruct.noise_std_detect]);
    common_noise_std_sorted = min([outputStruct.noise_std_sorted]);

    for i = 1:length(channelFiles)
        outputStruct(i).thrmax = maxThr;
        outputStruct(i).noise_std_detect = common_noise_std_detect;
        outputStruct(i).noise_std_sorted = common_noise_std_sorted;
        outputStruct(i).thr = thr_all;
    end