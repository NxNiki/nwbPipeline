function destFig = duplicateFigure(sourceFig,destFig,replace,copyTitle)

if nargin<3
    replace = 0;
end
if nargin<4
    copyTitle=1;
end

if nargin<2
    destFig=figure;
    delete(get(destFig,'children'))
    dest = 'fig';
elseif strcmpi(get(destFig,'type'),'figure')
    dest = 'fig';
    set(0,'CurrentFigure',destFig)
else
    assert(strcmpi(get(destFig,'type'),'axes'),'destFig must be a figure or an axes');
    try
        % These lines of code break if destination is an axes whose parent
        % is a panel. But it doesn't seem to matter if we skip over them.
        % It's possible that we could remove these lines entirely, but I'm
        % leaving them here just in case, since I'm not sure if I truly
        % needed them at some point....
        set(0,'currentfigure',get(destFig,'parent'));
        set(get(destFig,'parent'),'currentaxes',destFig);%axes(destFig);
    end
    dest = 'axes';
end

if replace
    switch dest
        case 'fig'
            delete(get(destFig,'children'))
%             clf(destFig)
        case 'axes'
            cla(destFig)
    end
elseif strcmp(get(sourceFig,'type'),'axes')
    hold on
end
%objects=allchild(sourceFig);
switch dest
    case 'fig'
        if strcmp(get(sourceFig,'type'),'axes')
            % from axes to fig
            assert(length(get(destFig,'children'))==1,...
                'You may only copy an axes object into a figure with a single axes object.')
            src = get(sourceFig,'children');
            dst = get(destFig,'children');
            srcTitle = get(sourceFig,'title');
            dstTitle = get(get(destFig,'children'),'title');
        else
            % from fig to fig
            src = get(sourceFig,'children');
            dst = destFig;
        end
    case 'axes'
        if strcmp(get(sourceFig,'type'),'axes')
            % from axes to axes
            src = get(sourceFig,'children');
            dst = destFig;
            srcTitle = get(sourceFig,'title');
            dstTitle = get(destFig,'title');
        else
            % from fig to axes
            assert(length(get(sourceFig,'children'))==1,...
                'You may only copy a figure with a single axes object into an axes object.')
            src = get(get(sourceFig,'children'),'children');
            dst = destFig;
            srcTitle = get(get(sourceFig,'children'),'title');
            dstTitle = get(destFig,'title');
        end
end
copyobj(src,dst);
if copyTitle&&exist('srcTitle','var')
set(dstTitle,'interpreter',get(srcTitle,'interpreter'),'string',get(srcTitle,'string'))
end