function [handles, clustering_results, tree] = rejectCluster(hObject, handles, clusterIdx)

    switch clusterIdx
        case 1
            set(handles.isi1_accept_button, 'value', 0);
        case 2
            set(handles.isi2_accept_button, 'value', 0);
        case 3
            set(handles.isi3_accept_button, 'value', 0);
    end
    
    [tree, classes, clustering_results] = getUserData([5,6,10]);

    classes(classes==clusterIdx) = 0;
    classes = shrinkClassIndex(classes);
    setUserData(classes, [6, 9]);

    if ~isempty(hObject)
        guidata(hObject, handles);
    end

end
