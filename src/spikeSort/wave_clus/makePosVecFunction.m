function posVec = makePosVecFunction(nRows,nCols,borderBetweenRows,borderBetweenCols,outerBorder)
% SYNTAX: posVec = makePosVecFunction(nRows,nCols,borderBetweenRows,borderBetweenCols,outerBorder)
% defaults: outerBorder == .002;
%           borderbetweenRows = 0.025;
%           borderBetweenCols = 0.025
%
% I find Matlab's gui position vectors counter intuitive. I would rather
% design based on a grid. This allows me to convert my idea of a grid into
% Matlab's idea of a position vector. If you define the number of rows and
% columns in your grid, you can create a position vector by entering the
% column and row numbers, along with the number of columns and rows they
% span. In particular, the output of this function is a function with
% Arguments: the starting column number from left, the number of columns to span
%            the row number of the bottom  of the element counting from
%            top of the window, the number of rows to span,
%
%
% Note: This function expects and returns things in normalized units.
if nargin==0 || (nargin==1 && ischar(nRows) && strcmp(nRows,'?'))
    disp('The output of this function is a function with arguments: ')
    disp('(1) the starting column number from left,')
    disp('(2) the number of columns to span,')
    disp('(3) the row number of the bottom  of the element counting from top of the window,')
    disp('(4) the number of rows to span')
    return
end

if ~exist('outerBorder','var')||isempty(outerBorder)
outerBorder = .002;
end
if ~exist('borderBetweenRows','var')||isempty(borderBetweenRows)
borderBetweenRows = .025; %border between rows
end
if ~exist('borderBetweenCols','var')||isempty(borderBetweenCols)
borderBetweenCols = .025; %border between cols
end

h = (1-(nRows-1)*borderBetweenRows-2*outerBorder)/nRows; %rowHeight
w = (1-(nCols-1)*borderBetweenCols-2*outerBorder)/nCols; %column width

posVec = @(colNum,colsToSpan,rowNum,rowsToSpan)...
    [outerBorder+(colNum-1)*(borderBetweenCols+w),...
    (nRows-rowNum)*(borderBetweenRows+h)+outerBorder,...
    (w+borderBetweenCols)*colsToSpan-borderBetweenCols,...
    (h+borderBetweenRows)*rowsToSpan-borderBetweenRows];
