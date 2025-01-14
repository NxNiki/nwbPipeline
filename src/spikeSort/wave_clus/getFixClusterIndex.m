function clustersFixedIdx = getFixClusterIndex(handles)

USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};

clustersFixedIdx = logical(par.max_clus);
for i = 1:par.max_clus
    if i <= 3
        clustersFixedIdx(i) = get(handles.(['fix' num2str(i), '_button']), 'value');
    else
        clustersFixedIdx(i) = par.(['fix', num2str(i)]);
    end
end