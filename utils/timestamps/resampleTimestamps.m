function resampleTimestamps = resampleTimestamps(timestamps, resampleFS)
% resample timestamps according to given sampling frequency.

compressed_ts = compressTimestamps(timestamps);
resampleTimestamps = [];
for i = 1: size(resampleTimestamps, 1)
    resampleTimestamps = [resampleTimestamps, compressed_ts(i, 1): resampleFS: compressed_ts(i, 3)];
end

end