function update_fix_button(handles, plotIdx)
    % get the fix_button state of current UI and update the main UI
    
    clusterIdx = handles.clusterIdx(plotIdx);
    plotLabelIdx = handles.plotLabelIdx(plotIdx);
    
    mainHandles = getHandles(1);

    if get(handles.(sprintf('fix%d_button', plotLabelIdx)), 'value') == 1
        mainHandles.clusterFixed(clusterIdx) = 1;
    else
        mainHandles.clusterFixed(clusterIdx) = 0;
    end
    
end