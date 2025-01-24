function unFixAllClusters()
% get the indices of clusters that the fix button is pressed in the current
% handle.

[uiHandles, handlesIndex] = getHandles();

for i = 1:length(uiHandles)

    handles = guidata(uiHandles(i));

    if handlesIndex(i) == 1
        % main handle
        startClusterIdx = 1;
        endClusterIdx = 3;
    else
        % aux handles
        startClusterIdx = 4;
        endClusterIdx = 8;
    end
    for j = startClusterIdx: endClusterIdx
        set(handles.(['fix' num2str(j), '_button']), 'value', 0);
    end

    guidata(uiHandles(i), handles);
end
