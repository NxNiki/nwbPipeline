function handles = updateHandles(handles, fieldsTrue, fieldsFalse, clusterIdx)
    if nargin < 2
        fieldsTrue = [];
    end
    if nargin < 3
        fieldsFalse = [];
    end
    if nargin < 4
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
end