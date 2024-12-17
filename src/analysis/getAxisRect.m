function [rect] = getAxisRect(pos, sub_pos, nCols, nRows)
% sub_pos: row of sub position for a stim. 1: top, 2: middle, 3: bottom.
% nCols: number of columns of raster plots in each page.
% nRows: number of rows of raster plots in each page.
% number of rows for a single stim. usually 3, top: image, middle:
%   raster plots, bottom: histgram of inter-spike intervals.

    if nargin < 3
        nCols = 6; nRows = 3;
    end

    top = .025; bottom = .025; horizonEdge = .025; horiz = .025;
    verticalMaj = .05;
    if sub_pos == 0
        % for rasters by image, only one raster plot in each block:
        imageVert = .15;
        pos = pos - 1;
        verticalSize = (1 - top - bottom - imageVert - nRows*verticalMaj)/nRows;
        horizSize = (1 - 2*horizonEdge - (nCols-1)*horiz)/nCols;        
    else
        % for rasters by unit, show image, raster plot and histgram in each 
        % block.
        verticalMin = .025; 
        blockHeight = (1 - top - bottom - nRows*verticalMaj - 2*nRows*verticalMin)/nRows;
        verticalMajSize = 2/5 * blockHeight;
        verticalMinSize = 1/5 * blockHeight;
        horizSize = (1 - 2*horizonEdge - (nCols-1)*horiz)/nCols;
        if sub_pos == 1
            subpos_factor = verticalMinSize + verticalMajSize + 2 * verticalMin;
        elseif sub_pos == 2
            subpos_factor = verticalMinSize + verticalMin;
        else
            subpos_factor = 0;
        end
    end

    vertNum = floor(pos/nCols) + 1;
    horzNum = mod(pos, nCols) + 1;

    rect(1) = horizonEdge + (horzNum-1)*(horizSize+horiz);
    if sub_pos > 0
        rect(2) = bottom + (nRows-vertNum)*(2*verticalMajSize+verticalMinSize+verticalMaj+2*verticalMin) + subpos_factor;
    else
        % for image rasters:
        rect(2) = bottom + (nRows-vertNum)*(verticalSize+verticalMaj);
    end
    rect(3) = horizSize;
    if sub_pos == 0
        rect(4) = verticalSize;
    elseif sub_pos < 3
        rect(4) = verticalMajSize;
    else
        rect(4) = verticalMinSize;
    end

end

% function [rect] = getAxisRect(pos)
% vertNum = floor((pos-1)/6)+1;
% horzNum = mod(pos-1, 6) + 1;
% 
% nCols = 6; nRows = 8;
% 
% top = .025; bottom = .025; edge = .015; vertic = .05;  horiz = .025;
% imageVert = .15;
% 
% verticalSize = (1 - top - bottom - imageVert - nRows*vertic)/nRows;
% horizSize = (1 - 2*edge - (nCols-1)*horiz)/nCols;
% 
% 
% rect(1) = edge + (horzNum-1)*(horizSize+horiz);
% rect(2) = bottom + (nRows-vertNum)*(verticalSize+vertic);
% rect(3) = horizSize;
% rect(4) = verticalSize;
% end