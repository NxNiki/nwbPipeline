function max_value = getMaxSamplingInterval(timestamps, fraction_threshold)
    % getMaxSamplingInterval finds the maximum timestamp with a frequency
    % greater than a specified fraction of the total number of timestamps.
    %
    % INPUT:
    %   timestamps - A vector of timestamps.
    %   fraction_threshold - A fraction (e.g., 10 for 1/10) representing the
    %                        minimum frequency required for a timestamp to be
    %                        considered. The frequency is calculated as
    %                        (length(timestamps) / fraction_threshold).
    %
    % OUTPUT:
    %   max_value - The maximum timestamp that occurs more frequently than
    %               the specified fraction of the total number of timestamps.
    %               Returns NaN if no timestamp meets the frequency criterion.

    timestamps = diff(timestamps);
    % Calculate the frequency threshold
    min_frequency = length(timestamps) / fraction_threshold;

    % Get unique timestamps and their frequencies
    [unique_timestamps, ~, index] = unique(timestamps);
    frequencies = histc(index, 1:length(unique_timestamps));

    % Filter timestamps with frequency greater than the threshold
    valid_timestamps = unique_timestamps(frequencies > min_frequency);

    % Find the maximum value among the filtered timestamps
    if ~isempty(valid_timestamps)
        max_value = max(valid_timestamps);
    else
        error("no valid sampling interval found. Make sure timestamps is regularly sampled!")
    end
end
