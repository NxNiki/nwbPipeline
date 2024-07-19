function [handles, USER_DATA, tree] = rejectCluster(hObject, handles, clusterIdx)

    switch clusterIdx
        case 1
            set(handles.isi1_accept_button, 'value', 0);
        case 2
            set(handles.isi2_accept_button, 'value', 0);
        case 3
            set(handles.isi3_accept_button, 'value', 0);
    end

    USER_DATA = get(handles.wave_clus_figure, 'userdata');
    classes = USER_DATA{6};
    tree = USER_DATA{5};
    classes(classes==clusterIdx) = 0;
    USER_DATA{6} = classes;
    USER_DATA{9} = classes;
    set(handles.wave_clus_figure, 'userdata', USER_DATA);

    if ~isempty(hObject)
        guidata(hObject, handles)
    end

end