function [rect] = getAxisRect(pos, sub_pos, nCols, nRows)

    if nargin < 3
        nCols = 6; nRows = 3;
    end

    vertNum = floor(pos/6) + 1;
    horzNum = mod(pos, 6) + 1;

    top = .025; bottom = .025; edge = .025; verticalMaj = .05; verticalMin = .025; horiz = .025;
    verticalMajSize = 2/5*(1 - top - bottom - nRows*verticalMaj - 2*nRows*verticalMin)/nRows;
    verticalMinSize = 1/5*(1 - top - bottom - nRows*verticalMaj - 2*nRows*verticalMin)/nRows;
    horizSize = (1 - 2*edge - (nCols-1)*horiz)/nCols;

    if sub_pos == 1
        subpos_factor = verticalMinSize + verticalMajSize + 2 * verticalMin;
    elseif sub_pos == 2
        subpos_factor = verticalMinSize + verticalMin;
    else
        subpos_factor = 0;
    end

    rect(1) = edge + (horzNum-1)*(horizSize+horiz);
    rect(2) = bottom + (nRows-vertNum)*(2*verticalMajSize+verticalMinSize+verticalMaj+2*verticalMin) + subpos_factor;
    rect(3) = horizSize;
    if sub_pos == 1 || sub_pos == 2
        rect(4) = verticalMajSize;
    else
        rect(4) = verticalMinSize;
    end
end