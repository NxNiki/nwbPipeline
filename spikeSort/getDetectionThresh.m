function [thr, outputStruct] = getDetectionThresh(x, param, maxAmp)
% Does the first few steps of spike detection to find the threshold. This
% allows for using the same threshold across multiple sessions. Returns
% thr, as well as a struct with other variables created so that these steps
% can be skipped in spikeDetect if the struct is passed in.


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
thr = stdmin * noise_std_detect;        %thr for detection is based on detect settings.
thrmax = min(maxAmp, stdmax * noise_std_sorted);     %thrmax for artifact removal is based on sorted settings.

outputStruct.xf = xf;
outputStruct.xf_detect = xf_detect;
outputStruct.noise_std_detect = noise_std_detect;
outputStruct.noise_std_sorted = noise_std_sorted;
outputStruct.thr = thr;
outputStruct.thrmax = thrmax;