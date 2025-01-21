function clustersFixedIdx = getFixClusterIndex()
% get the indices of clusters that the fix button is pressed in the current
% handle.

clustersFixedIdx = false(1, 33);
numClustersInUI = [1, 3, 5, 5, 5, 5, 5, 5];
UITags = {'wave_clus_figure', 'wave_clus_aux', 'wave_clus_aux1', 'wave_clus_aux2', 'wave_clus_aux3', 'wave_clus_aux4', 'wave_clus_aux5'};

for ui_idx = 1:length(UITags)
    ui = findobj('tag', UITags{ui_idx}, 'Visible', 'on');
    
    if isempty(ui)
        continue;
    end
    handles = guidata(ui);

    startClusterIdx = sum(numClustersInUI(1:ui_idx));
    endClusterIdx = sum(numClustersInUI(1:ui_idx+1)) - 1;
    for i = startClusterIdx: endClusterIdx
        clustersFixedIdx(i) = get(handles.(['fix' num2str(i), '_button']), 'value');
    end
end

clustersFixedIdx = find(clustersFixedIdx);