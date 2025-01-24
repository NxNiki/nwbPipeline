function update_fix_button(handles, plotIdx)
    clusterIdx = handles.clusterIdx(plotIdx);
    plotLabelIdx = handles.plotLabelIdx(plotIdx);

    par = getUserData(1);
    if get(handles.(sprintf('fix%d_button', plotLabelIdx)), 'value') == 1
        par.(sprintf('fix%d', clusterIdx)) = 1;
    else
        par.(sprintf('fix%d', clusterIdx)) = 0;
    end
    
    setUserData(par, 1);
end