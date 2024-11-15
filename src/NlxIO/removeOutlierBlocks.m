function signal_processed = removeOutlierBlocks(singal, timestamps)
% signal: 512 by n
% timestamps: 1 by n
% threshold: seconds.
% samplingRate: Hz

threshRatio = 10/512;

tsdiff = diff(timestamps);
medianTsDiff = median(tsdiff);

blockWithLargeGap = tsdiff > medianTsDiff * (1 + threshRatio);
blockWithSmallGap = tsdiff < medianTsDiff * (1 - threshRatio);
signal_processed = singal;
signal_processed(:, blockWithLargeGap | blockWithSmallGap) = -inf;


end