function ax = subplot2(a,b,i,j,varargin)
% SYNTAX: ax = subplot2(a,b,i,j,varargin)
%
% Matlab's subplot function is inconvenient if you want to index the
% subplot by its horizontal and vertical location. This fixes that.
% subplot2(a,b,i,j) will create a subplot at the i,j_th
% position, assuming a total of a-by-b subplots. This is equivalent to
% calling subplot(a,b,b*(i-1)+j). The function returns ax, the axes handle
% to the plot. varargin are passed on to subplot.
% You may also include the parameter-value pair 'borderPct',val as part of
% the optional arguments. This is most handy for diminishing the amount of
% white-space left between plots, as Matlab's default amount is quite high.
% Be warned, however, that if a and b are large, in expanding one subplot,
% Matlab sometimes deletes a subplot to the left. This can generally be
% worked around by creating all axes and then re-creating any that get
% deleted.
%
% If you would like to stretch an axis to cover a larger area, you may
% enter i and j as 2-element vectors, indicating the first and last subplot
% region you wish to cover.
% For example, try this code:
% figure;
% subplot2(3,3,1,1); subplot2(3,3,1,2); subplot2(3,3,1,3);
% subplot2(3,3,[2 3],[1 3]);  %This plot covers rows 2-3 and columns 1-3 of
% a 3x3 grid.
%
% If you want to create a pair of panels that live in the same subplot
% space, you can include arguments such as {'top',.7} or {'right',.5}. In
% this case the axes would be created in the upper 70% or right 50% of
% where they would have been created. These might be paired later with
% {'bottom',.3} or {'left',.5} to have seamless pairs of axes within a
% single subplot space. You may also use {'horizSpan',[.25 .75]} or
% {'vertSpan',[.3 .7]} if you want to specify the middle portion of an
% area.
%
% Written by Emily Mankin, (c) 2012

if ~exist('j','var') || isempty(j)
    [j,i] = ind2sub([b,a],i);
end

parent = find(cellfun(@(x)~isempty(regexpi(x,'parent', 'once')),varargin(1:2:end)));
parent = parent*2-1;
if ~isempty(parent)
    set(0,'currentfigure',varargin{parent+1})
    varargin(parent:parent+1) = [];
end

pctInd = find(cellfun(@(x)~isempty(regexpi(x,'borderPct', 'once')),varargin(1:2:end)));
pctInd = pctInd*2-1;
if ~isempty(pctInd)
    pct = varargin{pctInd+1};
    varargin(pctInd:pctInd+1) = [];
else
    pct = 0.05;
end

posOnly = find(cellfun(@(x)~isempty(regexpi(x,'pos(ition)?Only', 'once')),varargin(1:2:end)));
posOnly = posOnly*2-1;
if isempty(posOnly)
    posOnly = 0;
end

vertInd = find(cellfun(@(x)~isempty(regexpi(x,'vertSpan', 'once')),varargin(1:2:end)));
vertInd = vertInd*2-1;
if ~isempty(vertInd)
    vertSpan = varargin{vertInd+1};
    varargin(vertInd:vertInd+1) = [];
    if max(vertSpan) > 1.5
        vertSpan = vertSpan/100;
    end
else
    topInd = find(cellfun(@(x)~isempty(regexpi(x,'top', 'once')),varargin(1:2:end)));
    topInd = topInd*2-1;
    if ~isempty(topInd)
        top = varargin{topInd+1};
        varargin(topInd:topInd+1) = [];
        if top > 1
            top = top/100;
        end
        vertSpan = [1-top 1];
    else
        bottomInd = find(cellfun(@(x)~isempty(regexpi(x,'bottom', 'once')),varargin(1:2:end)));
        bottomInd = bottomInd*2-1;
        if ~isempty(bottomInd)
            bottom = varargin{bottomInd+1};
            varargin(bottomInd:bottomInd+1) = [];
            if bottom > 1
                bottom = bottom/100;
            end
            vertSpan = [0 bottom];
        else
            vertSpan = [0 1];
        end
    end
end

horizInd = find(cellfun(@(x)~isempty(regexpi(x,'horizSpan', 'once')),varargin(1:2:end)));
horizInd = horizInd*2-1;
if ~isempty(horizInd)
    horizSpan = varargin{horizInd+1};
    varargin(horizInd:horizInd+1) = [];
    if max(horizSpan) > 1.5
        horizSpan = horizSpan/100;
    end
else
    leftInd = find(cellfun(@(x)~isempty(regexpi(x,'left', 'once')),varargin(1:2:end)));
    leftInd = leftInd*2-1;
    if ~isempty(leftInd)
        left = varargin{leftInd+1};
        varargin(leftInd:leftInd+1) = [];
        if left > 1
            left = left/100;
        end
        horizSpan = [0 left];
    else
        rightInd = find(cellfun(@(x)~isempty(regexpi(x,'right', 'once')),varargin(1:2:end)));
        rightInd = rightInd*2-1;
        if ~isempty(rightInd)
            right = varargin{rightInd+1};
            varargin(rightInd:rightInd+1) = [];
            if right > 1
                right = right/100;
            end
            horizSpan = [1 - right, 1];
        else
            horizSpan = [0 1];
        end
    end
end

if length(i)==1
    i = [i i];
end
if length(j)==1
    j = [j j];
end

posVec = makePosVecFunction(a, b, 2*pct, pct, pct);
pos = posVec(min(j),diff(j)+1,max(i),diff(i)+1);
x=pos(1); y = pos(2); w = pos(3); h = pos(4);
newX = x + horizSpan(1)*w; newW = diff(horizSpan)*w;
newY = y + vertSpan(1)*h; newH = diff(vertSpan)*h;
pos = [newX newY newW newH];

if posOnly
    ax = pos;
else

ax = axes('position',pos,...
    'units','normalized',varargin{:});
end
% else
%     ax = subplot(a,b,b*(i-1)+j,varargin{:});
% end