function [position, position_idx] = findFirstOccurrence(array)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

unique_vals = unique(array);
position = zeros(length(unique_vals), 1);
position_idx = zeros(length(array), 1);

for i = 1: length(array)
    if position(array(i)==unique_vals) == 0
        position(array(i)==unique_vals) = i;
        position_idx(i) = 1;
    end
end