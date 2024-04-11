function [lfp, regularTimestamps] = combineLFP(lfps, timestamps, fs)
% combine segments of LFP and fill gaps with NaNs at downsampled frequency.
% timestamps is converted from UNIX time to zero based. Missing values are
% filled according to fs.

% unfinished. In case we want to extract LFP for each segments and combine
% LFP afterwards...

if length(lfps) ~= length(timestamps)
    error('input length not match!')
end







