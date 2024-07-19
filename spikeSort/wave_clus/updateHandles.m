function handles = updateHandles(hObject, handles, fieldsTrue, fieldsFalse, clusterIdx, minclus)
% set handles to 1 for keys in fieldsTrue and 0 for keys in fieldsFalse.
% if clusterIdx is set, load USER_DATA and get minclus. Otherwise set
% minclus directly. If both clusterIdx and minclus are empty, minclus is
% not set.

    if nargin < 3
        fieldsTrue = [];
    end
    if nargin < 4
        fieldsFalse = [];
    end
    if nargin < 5
        clusterIdx = [];
    end
    if nargin < 6
        minclus = [];
    end

    if ~isempty(clusterIdx)
        USER_DATA = get(handles.wave_clus_figure, 'userdata');
        cluster_results = USER_DATA{clusterIdx};
        handles.minclus = cluster_results(1, 5);
    elseif ~isempty(minclus)
        handles.minclus = minclus;
    end

    for i = 1:length(fieldsTrue)
        handles.(fieldsTrue{i}) = 1;
    end

    for i = 1:length(fieldsFalse)
        handles.(fieldsFalse{i}) = 0;
    end
    
    if ~isempty(hObject)
        guidata(hObject, handles);
    end

end