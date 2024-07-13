function updateHandles(hObject, handles, fieldsTrue, fieldsFalse, clusterIdx)
    if nargin < 3
        fieldsTrue = [];
    end
    if nargin < 4
        fieldsFalse = [];
    end
    if nargin < 5
        clusterIdx = 10;
    end
    
    USER_DATA = get(handles.wave_clus_figure, 'userdata');
    cluster_results = USER_DATA{clusterIdx};
    handles.minclus = cluster_results(1, 5);

    for i = 1:length(fieldsTrue)
        handles.(fieldsTrue{i}) = 1;
    end

    for i = 1:length(fieldsFalse)
        handles.(fieldsFalse{i}) = 0;
    end

    guidata(hObject, handles);
end