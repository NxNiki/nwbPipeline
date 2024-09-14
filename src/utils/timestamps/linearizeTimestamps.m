function timestampsOut = linearizeTimestamps(timestampsIn, Fs)
    % create a linearized timetamps with fixed sampling intervals.
    % skip gaps larger than a threshold.
    % timestamps are assumed in unit of seconds.

    samplingInterval = 1 / Fs;
    tsDiff = diff(timestampsIn);
    gapIdx = find(tsDiff > median(tsDiff) * 2);
    minIntervalLength = 1 / median(tsDiff);

    if isempty(gapIdx)
        timestampsOut = timestampsIn(1): samplingInterval: timestampsIn(end);
        return
    end

    gapIdx = [0, gapIdx, length(timestampsIn)];
    timestampsOut = cell(1, length(gapIdx) - 1);
    for i = 2: length(gapIdx)
        if gapIdx(i) - gapIdx(i-1) >= minIntervalLength
            timestampsOut{i-1} = timestampsIn(gapIdx(i-1)+1): samplingInterval: timestampsIn(gapIdx(i));
        else
            timestampsOut{i-1} = [];
        end
    end
    timestampsOut = [timestampsOut{:}];
end
