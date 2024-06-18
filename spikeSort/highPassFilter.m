function [xf_detect, xf, noise_std_detect, noise_std_sorted, thr, thrmax] = highPassFilter(x, param)

    maxAmp = 500;
    sr = param.sr;
    stdmin = param.stdmin;
    stdmax = param.stdmax;
    fmin_detect = param.detect_fmin;
    fmax_detect = param.detect_fmax;
    fmin_sort = param.sort_fmin;
    fmax_sort = param.sort_fmax;
    
    %HIGH-PASS FILTER OF THE DATA
    if exist('ellip', 'file')                               % Checks for the signal processing toolbox
        [b_detect,a_detect] = ellip(param.detect_order, 0.1, 40, [fmin_detect fmax_detect]*2/sr);
        xf_detect = filtfilt(b_detect, a_detect, x);
        if fmin_sort ~= fmin_detect || fmax_sort ~= fmax_detect || param.sort_order ~= param.detect_order
            [b,a] = ellip(param.sort_order, 0.1, 40, [fmin_sort fmax_sort]*2/sr);
            xf = filtfilt(b, a, x);
        else
            xf = xf_detect;
        end
    else
        warning('ellip:notFound', 'ellip not found, use fix_filter to filter signal.');
        xf = fix_filter(x);                                 % bandpass filtering between [300 3000] without the toolbox.
        xf_detect = xf;
    end
    
    noise_std_detect = median(abs(xf_detect))/0.6745;
    noise_std_sorted = median(abs(xf))/0.6745;
    thr = stdmin * noise_std_detect;                        % thr for detection is based on detect settings.
    thrmax = min(maxAmp, stdmax * noise_std_sorted);        % thrmax for artifact removal is based on sorted settings.

end