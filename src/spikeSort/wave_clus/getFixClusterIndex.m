function clustersFixedIdx = getFixClusterIndex(handles, startIdx)
% get the indices of clusters that the fix button is pressed in the current
% handle.

if nargin < 2
    startIdx = 1;
end

if startIdx == 1
    num_clus = 3;
else
    num_clus = 5;
end

clustersFixedIdx = false(1, num_clus + startIdx - 1);
for i = startIdx: startIdx + num_clus - 1
    clustersFixedIdx(i) = get(handles.(['fix' num2str(i), '_button']), 'value');
end

clustersFixedIdx = find(clustersFixedIdx);