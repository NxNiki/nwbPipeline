function handles = updateHandles(hObject, handles, fieldsTrue, fieldsFalse)
% set handles to 1 for keys in fieldsTrue and 0 for keys in fieldsFalse.

    if nargin < 3
        fieldsTrue = [];
    end
    if nargin < 4
        fieldsFalse = [];
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
