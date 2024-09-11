function [position, position_idx] = findFirstOccurrence(array)
%findFirstOccurrence find the position of the first occurrence in an array.
%   This is used to find the index of first suffix in neuralynx segements
%   to decide whether to compute timestamps. As timestamps are same across
%   channel, we only do this for the first file (segments).
%
%   array: cell (n, 1) or vector.

unique_vals = unique(array);
position = zeros(length(unique_vals), 1);
position_idx = zeros(length(array), 1);

for i = 1: length(array)
    if position(array(i)==unique_vals) == 0
        position(array(i)==unique_vals) = i;
        position_idx(i) = 1;
    end
end