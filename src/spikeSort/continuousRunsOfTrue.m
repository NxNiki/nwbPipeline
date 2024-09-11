function [ result ] = continuousRunsOfTrue( logical_arr )
%CONTINUOUSRUNSOFTRUE returns indices of continuous runs of true in a
%logical array

% Christopher Dao, 6.27.29

% the start of continuous runs are where 0 turns to 1 and the ends of
% the runs are where 1 turns to 0
arr = diff(logical_arr);
startIndices = find(arr == 1) + 1;
stopIndices = find(arr == -1);

% if the first index is a 1, then 1 should be included in startIndices
if logical_arr(1)
    startIndices = [1, startIndices];
end
% if the last index is a 1, then the last index should be included in
% stopIndices

if logical_arr(end)
    stopIndices = [stopIndices, length(logical_arr)];
end

% concatenate the start and stop array indices for the final result
result = [startIndices', stopIndices'];

end

