function res = flatten(cellArray)
%FLATTEN Flatten a nested cell array into a single cell array.
%   RES = FLATTEN(CELLARRAY) recursively flattens the nested cell array
%   CELLARRAY into a single cell array RES.
%
%   If CELLARRAY is not a cell array, it is wrapped into a cell array
%   before returning.
%
%   Example:
%{
      cellArray = {[1,2], {2, 3}, 'a', {'b'}, {{4}, 5}};
      res = flatten(cellArray)
%}

if ~iscell(cellArray)
    res = {cellArray};
    return
else
    res = [];
    for i = 1:length(cellArray)
        res = [res, flatten(cellArray{i})];
    end
end
end
