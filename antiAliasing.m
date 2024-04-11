function [lfpSignal, downSampledTimestamps, timestampStart] = antiAliasing(cscSignal, timestamps)
% downsample csc signal to 2kHz

% this is the one I would recommend using but open to other options
f_info.Fs = 32000;
f_info.Fpass = 300;         % Passband Frequency
f_info.Fstop = 1000;        % Stopband Frequency
f_info.Apass = 0.0001;      % Passband Ripple (dB)
f_info.Astop = 65;          % Stopband Attenuation (dB)
f_info.match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its CHEBY2 method.
h  = fdesign.lowpass(f_info.Fpass, f_info.Fstop, f_info.Apass, f_info.Astop, f_info.Fs);
Hd = design(h, 'cheby2', 'MatchExactly', f_info.match);

f_info.order = filtord(Hd.sosMatrix);
f_info.stable = isstable(Hd);
f_info.type = 'cheby2';

% also need to account for the fact that the output from Nlx_readCSC may
% contain NaNs.
nan_idx = isnan(cscSignal);

% fill in any NaN so we can filter (this is slow)
if ~sum(nan_idx)
    cscSignal = fillmissing(cscSignal, 'linear', 1, 'EndValues', 'nearest');
end

% filter the data
flt_data_conc = filtfilthd(Hd, cscSignal);

% add the NaNs back in
flt_data_conc(nan_idx) = NaN;

% downsampling to 2k using interp1
% we will also use this step to make the data points regularly sampled and
% have no large time gaps
% for interp1 to fill time gaps with add a NaN between data from each recording 
% and add a corresponding timestamp to the time
% but we only want to do this if there is a time gap between the recordings

% create a 2kHz time vector that spans the full series
ts_2k = timestamps(1):1/2000:timestamps(end);

lfpSignal = interp1(timestamps, flt_data_conc, ts_2k);
downSampledTimestamps = ts_2k - ts_2k(1);
timestampStart = ts_2k(1);
