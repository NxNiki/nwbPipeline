function filled_data = fillMissingData(timestamps_ref, timestamps_missing, data_missing)
% insert data with NaNs according to timestamps. data_missing has missing
% samples, timestamps_missing has the same size as data_missing with
% corresponding timestamps. timestamps is the complete timestamp. This
% function insert NaNs into data_missing according to the complete
% timestamp by finding the index of the each value in data_missing in the
% filled_data.
% if tolerance is large, the nearest value in data_missing will be
% inserted.

    sampling_interval = median(diff(timestamps_ref));

    % if the difference between timestamps and timestamps_missing is
    % less than tolerance, they will be considered as match sample.
    tolerance = sampling_interval * .5;

    % Initialize filled_data with -inf will be -32768 in int16.
    filled_data = int16(zeros(size(timestamps_ref))) - inf;

    % detect gaps in timestamps_missing:
    gap_index = [0; find(diff(timestamps_missing(:)) > sampling_interval * 2); length(timestamps_missing(:))];

    for i = 1:(length(gap_index) - 1)
        start_index = gap_index(i) + 1;
        end_index = gap_index(i + 1);
        fprintf('fill missing data on block: %d - %d\n', start_index, end_index);
        
        % get start index on the complete timestamp:
        [min_diff, start_index_ref] = min(abs(timestamps_ref - timestamps_missing(start_index)));
        
        if min_diff > tolerance
            warning('large differences in timestamps: %f', min_diff);
        end
        
        % Fill in data_missing values at the closest indices within tolerance
        filled_data(start_index_ref: start_index_ref+(end_index - start_index)) = data_missing(start_index: end_index);
    end

    filled_data = int16(filled_data);
end
