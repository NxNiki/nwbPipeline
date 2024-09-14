function result = combineCellArrays(rowElements, colElements, delimiter)
%COMBINECELLARRAYS Concatenates elements from two cell arrays into a new cell array.
%   RESULT = COMBINECELLARRAYS(CELLARRAY1, CELLARRAY2) returns a cell array where each element
%   is a concatenation of an element from CELLARRAY1 and an element from CELLARRAY2. Cell arrays
%   CELLARRAY1 and CELLARRAY2 should contain strings or characters.
%
%   RESULT is a numel(CELLARRAY1) by numel(CELLARRAY2) cell array, where the (i, j)-th element is
%   the concatenation of CELLARRAY1{i} and CELLARRAY2{j}.
%
%   Example:
%{
      fruits = {'apple', 'banana'};
      colors = {'red', 'yellow', 'green'};
      result = combineCellArrays(fruits, colors);
      disp(result);
%}
%   See also CELL, CELLFUN, MESHGRID, RESHAPE.

if nargin < 3
    delimiter = '_';
end

numRow = numel(rowElements);
numCol = numel(colElements);

% Create all combinations of indices
[indiceCol, indiceRow] = meshgrid(1:numCol, 1:numRow);

% Create the cell array by concatenating elements from CELLARRAY1 and CELLARRAY2
result = arrayfun(@(i, j) [rowElements{i}, delimiter, colElements{j}], indiceRow, indiceCol, UniformOutput=false);

end
