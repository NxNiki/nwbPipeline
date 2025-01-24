function clustersFixedIdx = getFixClusterIndex()
% get the indices of clusters that the fix button is pressed in the current
% handle.

clustersFixedIdx = false(1, 33);

h_figs = get(0, 'children');
UITags = {'wave_clus_figure', 'wave_clus_aux', 'wave_clus_aux1', 'wave_clus_aux2', 'wave_clus_aux3', 'wave_clus_aux4', 'wave_clus_aux5'};

numClusters = 3;
cluster_idx_shift = 0;
plot_idx_shift = 0;
for ui_idx = 1:length(UITags)
    ui = findobj(h_figs, 'tag', UITags{ui_idx}, 'Visible', 'on');
    
    if isempty(ui)
        continue;
    end
    handles = guidata(ui);
    % Todo: use handle.plotLabelIdx to get fix_buttons.
    % Todo: use handle.clusterIdx.
    
    if ui_idx > 1
        numClusters = 5;
        cluster_idx_shift = 3 + (ui_idx - 2) * 5;
        plot_idx_shift = 3;
    end
    for plot_idx = 1: numClusters
        cluster_idx = cluster_idx_shift + plot_idx;
        clustersFixedIdx(cluster_idx) = get(handles.(['fix' num2str(plot_idx + plot_idx_shift), '_button']), 'value');
    end
end

clustersFixedIdx = find(clustersFixedIdx);