function timestamps = uncompressTimestamps(compressedTimestamps)
% convert compressed timestamps to original format.

% see compressTimestamps.m


timestamps = [];

for i = 1: size(compressedTimestamps, 1)
    timestamps = [timestamps(:)', compressedTimestamps(i, 1): compressedTimestamps(i, 2): compressedTimestamps(i, 3)];
end

end
