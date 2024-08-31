function [gap_index, sampling_interval] = getTimestampGap(timestamps, threshold)
% find the gap in timestamps with time interval between adjacent timestamps
% larger than a threshold. timestamps should be regularly sampled with
% sporadic gaps.

if nargin < 2
    threshold = 'min';
end

timestamps_diff = diff(timestamps);

if length(unique(timestamps_diff)) > length(timestamps_diff) / 100
    warning("more than 100 gaps detected, timestamps may not be regularly sampled")
end

if isnumeric(threshold)
    sampling_interval_thresh = threshold;
else
    switch threshold
        case 'min'
            sampling_interval_thresh = min(timestamps_diff);
        case 'median'
            sampling_interval_thresh = median(timestamps_diff);
        case 'mode'
            sampling_interval_thresh = mode(timestamps_diff);
        otherwise
            error("undefined threhold, choose 'min', 'median' or mode")
    end
end

gap_index = find(timestamps_diff > sampling_interval_thresh);
sampling_interval = mean(timestamps_diff <= sampling_interval_thresh);

end