function compressedTs = compressTimestamps(timestamps)
% the regular sampled timestamps takes lots of storage space. this function
% compress timestamps by converting it to start and end timestamps with
% sampling interval. If multiple segments are detected, the output will
% have multiple rows. This is usually run after timestamps are linearized.

% compressedTS:
%   [startTS, samplingInterval, endTS]

% example:
%{
    ts = [1:1:10, 20:1:30, 40:1:60];
    cts = compressTimestamps(ts)
    unts = uncompressTimestamps(cts)
%}

% see also linearizeTimestamps.m, uncompressTimestamps.m


timestamps_diff = diff(timestamps);
sampling_interval = min(timestamps_diff);
gap_index = find(timestamps_diff > sampling_interval);

compressedTs = nan(length(gap_index) + 1, 3);
gap_index = [0, gap_index(:)', length(timestamps)];
for i = 1:length(gap_index) - 1
    ts_start = timestamps(gap_index(i) + 1);
    ts_end = timestamps(gap_index(i + 1));
    sampling_interval = (ts_end - ts_start) / (gap_index(i + 1) - gap_index(i) - 1);
    compressedTs(i, :) = [ts_start, sampling_interval, ts_end];
end