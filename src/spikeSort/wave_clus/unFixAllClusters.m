function unFixAllClusters()
% get the indices of clusters that the fix button is pressed in the current
% handle.

h_figs = get(0, 'children');
UITags = {'wave_clus_figure', 'wave_clus_aux', 'wave_clus_aux1', 'wave_clus_aux2', 'wave_clus_aux3', 'wave_clus_aux4', 'wave_clus_aux5'};
startClusterIdx = 1;
endClusterIdx = 3;
for ui_idx = 1:length(UITags)
    ui = findobj(h_figs, 'tag', UITags{ui_idx}, 'Visible', 'on');
    
    if isempty(ui)
        continue;
    end
    handles = guidata(ui);

    if ui_idx > 1
        startClusterIdx = 4;
        endClusterIdx = 8;
    end
    for i = startClusterIdx: endClusterIdx
        set(handles.(['fix' num2str(i), '_button']), 'value', 0);
    end
end
