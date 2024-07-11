function reorderSpikeRasters(newOrder)

if nargin==0
    keepGoing = 1;
    while keepGoing
        newOrder = input('What order?  ','s');
        switch newOrder
            case {'reset','rand','random','reverse','r'}
                % nothing to do, this is already in a good form
            case {'exit','done','0'}
                keepGoing = 0;
                return
            otherwise
                newOrder = eval(['[',newOrder,']']);
        end
        reorderSpikeRasters(newOrder);
    end
    return
end
                

% make sure newOrder is a row vector:
newOrder = newOrder(:)';
if ~ischar(newOrder)
newOrder = newOrder(end:-1:1);
end

% get data from wave_clus figure
waveClusFig = findobj('tag','wave_clus_figure');
handles = guidata(waveClusFig);
USER_DATA = get(handles.wave_clus_figure,'userdata');
spikeAx = findobj('tag','spikeRaster');
meanWaveformAx = handles.projections;
rasters = get(spikeAx,'children');
waveforms = get(meanWaveformAx,'children');

colors = reshape([rasters.Color],3,[])';
isBlack = ~sum(colors,2);
blackLines = rasters(isBlack); rasters(isBlack) = [];
clust0 = rasters(end); rasters(end) = [];
wave0 = waveforms(end); waveforms(end) = [];
nUnits = length(rasters);

currentOrder = USER_DATA{55};
if isempty(currentOrder)
%     currentOrderRasters = nUnits:-1:1;
    currentOrderUnitNums = nUnits:-1:1;
else
%     currentOrderRasters = currentOrder(1,:);
    currentOrderUnitNums = currentOrder(1,:);
end



% Get newOrder into the proper form:
if ischar(newOrder) 
    switch newOrder
        case 'reset'
            newOrder = nUnits:-1:1;
            newVisible = repmat({'on'},size(newOrder));
        case {'rand','random'}
            newOrder = randperm(nUnits);
            newVisible = repmat({'on'},size(newOrder));
        case {'r','reverse'}
            isVisible = cellfun(@(x)strcmp(x,'on'),{rasters.Visible});
            toReverse = currentOrderUnitNums(isVisible);
            newOrder = [currentOrderUnitNums(~isVisible),toReverse(end:-1:1)];
            newVisible = repmat({'off'},size(newOrder));
            newVisible(isVisible) = {'on'};
        otherwise
            error('newOrder must be a vector of cluster numbers OR the word ''reset'', ''random'', or ''reverse''');
    end
    
else
    % make sure all els are in the newOrder
    missingFromNew = find(~ismember(1:nUnits,newOrder));
    newVisible = [repmat({'off'},size(missingFromNew)) repmat({'on'},size(newOrder)) ];
    newOrder = [missingFromNew newOrder];
end

% first, sort into default order.

[defaultUnitNums,sortInds] = sort(currentOrderUnitNums);
rasters = rasters(sortInds);
waveforms = waveforms(sortInds);

% then sort into new order

rasters = [blackLines; rasters(newOrder); clust0];
waveforms = [waveforms(newOrder); wave0];
set(spikeAx,'children',rasters)
try
set(meanWaveformAx,'children',waveforms);
end
% newVisible = newVisible(end:-1:1);
% then make any that shouldn't be included invisible
newVisible = [repmat({'on'},1,length(blackLines)),newVisible,{'on'}]; % set clust 0 to visible
waveforms = [repmat(waveforms(1),length(blackLines),1); waveforms];

for i = 1:length(rasters)
    set(rasters(i),'visible',newVisible{i});
    set(waveforms(i),'visible',newVisible{i});
end

USER_DATA{55} = newOrder;
set(handles.wave_clus_figure,'userdata',USER_DATA);


1;