function exploreProjections(dest,allAxes,thisSyncBox,cutOnThisButton)
% by EM. Input is the destination axes; if called as part of
% Plot_all_features it will be a panel on the projections fig


% delete anything that already exists there for a new call to the function
ch = get(dest,'children');
delete(ch)
global checkboxes swatches axInd allAxChildren syncBox cutButton lastState
checkboxes = [];
swatches = [];
lastState = [];
if isempty(axInd),axInd= 1;end
allAxChildren = [];
if exist('thisSyncBox','var')
    syncBox = thisSyncBox;
end
if exist('cutOnThisButton','var')
    cutButton = cutOnThisButton;
end

% Set up blank axes
nRows = 8;
nCols = 6;
pv = makePosVecFunction(nRows,nCols);
set(dest,'units','normalized');
newAx = axes('parent',dest,'units','normalized', 'position',pv(1,nCols,nRows-2,nRows-2));



% Find all the axes that are in the projection window so that we can cycle
% through them

% f = get(dest,'parent');
% allAxes = get(f,'children'); 
% isAx = arrayfun(@(x)strcmp(get(x,'type'),'axes'),allAxes);
% 
% % delete anything that isn't axes
% allAxes = allAxes(isAx);
% % reorder so oldest is first
% allAxes = allAxes(end:-1:1); 
% set(allAxes,'XLimMode','manual','YLimMode','manual');

[x,y] = meshgrid(1:size(allAxes,2),1:size(allAxes,1));
allAxes = allAxes'; x=x'; y=y';
allAxes = allAxes(:); x = x(:); y = y(:);
empties = arrayfun(@(x)strcmp(class(x),'matlab.graphics.GraphicsPlaceholder'),allAxes);
allAxes(empties) = []; x(empties) = []; y(empties) = [];

if exist('thisSyncBox','var')
allAxChildren = arrayfun(@(x)els2cells(get(x,'children')),allAxes,'uniformoutput',0);
    set(syncBox,'callback',@SyncMainPanel);
end
if exist('cutOnThisButton','var')
    set(cutButton,'callback',{@cutOnThis,[x y]})
end

% Pick Projection Buttons
uicontrol('parent',dest,'units','normalized',...
    'position',pv(nCols,1,nRows-1,1),'style','pushbutton','string','Pick Projection',...
    'callback',{@pickProjection,newAx,dest,allAxes},'tag','choose');
uicontrol('parent',dest,'units','normalized',...
    'position',pv(nCols-0.5,0.5,nRows-1,1),'style','pushbutton','string','>',...
    'callback',{@pickProjection,newAx,dest,allAxes},'tag','next');
uicontrol('parent',dest,'units','normalized',...
    'position',pv(nCols-1,0.5,nRows-1,1),'style','pushbutton','string','<',...
    'callback',{@pickProjection,newAx,dest,allAxes},'tag','prev');

pickProjection([],[],newAx,dest,allAxes)
figure(get(dest,'parent'))



function pickProjection(varargin)
global checkboxes swatches axInd
newAx = varargin{3};
dest = varargin{4};
if isempty(varargin{1})
    varargin{1} = struct('Tag','this');
end
currentChildren = get(newAx,'children');
if ~isempty(currentChildren)
    mSize = get(currentChildren(1),'markerSize');
else
    mSize = 12;
end

allAxes = varargin{5};
if isempty(axInd) || axInd > length(allAxes) || axInd < 1;
    axInd = 0;
else
    set(allAxes(axInd),'visible','off')
end
switch varargin{1}.Tag
    case 'choose'
        axInd = []; attempt = 0;
        while isempty(axInd) && attempt<5
        ginput(1);
        attempt = attempt+1;
        ax1 = gca;
        axInd = find(ismember(allAxes,ax1));
        end
    case 'next'
        axInd = axInd+1;
        if axInd > length(allAxes)
            axInd = 1;
        end
    case 'prev'
        axInd = axInd - 1;
        if axInd < 1
            axInd = length(allAxes);
        end
    case 'this'
        % nothing to do, axInd stays the same
end
if axInd<1,axInd = 1;end
set(allAxes(axInd),'visible','on')
duplicateFigure(allAxes(axInd),newAx,1);
ch = get(newAx,'children');

nRows = 8;
nCols = max(6,length(ch));
pv = makePosVecFunction(nRows,nCols);

set(ch,'markersize',mSize)

if isempty(checkboxes)
    checkboxes = arrayfun(@(x)uicontrol('parent',dest,'units','normalized',...
        'position',pv(nCols + 1 - x,1,nRows,1),'style','checkbox','string','Show/Hide',...
        'backgroundcolor',ch(x).Color,'value',1,'callback',{@showHide,ch(x)}),1:length(ch),'uniformoutput',0);
    swatches = arrayfun(@(x)uicontrol('parent',dest,'units','normalized',...
        'position',pv(nCols + 1.5 - x,.5,nRows,.5),'style','pushbutton','string','Col',...
        'backgroundcolor',ch(x).Color,'callback',{@changeColor,ch(x),x}),1:length(ch),'uniformoutput',0);
else
    for x = 1:length(checkboxes)
        set(checkboxes{x},'callback',{@showHide,ch(x)});
        set(swatches{x},'callback',{@changeColor,ch(x),x});
        if checkboxes{x}.Value
            set(ch(x),'visible','on','color',checkboxes{x}.BackgroundColor)
        else
            set(ch(x),'visible','off','color',checkboxes{x}.BackgroundColor)
        end
    end
end
uicontrol('parent',dest,'units','normalized',...
    'position',pv(1,1,nRows-1,1),'style','pushbutton','string','Show All',...
    'callback',{@showHideAll,ch,'on'});
uicontrol('parent',dest,'units','normalized',...
    'position',pv(2,1,nRows-1,1),'style','pushbutton','string','Hide All',...
    'callback',{@showHideAll,ch,'off'});
sizeDecrease = uicontrol('parent',dest,'units','normalized',...
    'position',pv(3,.5,nRows-1,.5),'style','pushbutton','string','v',...
    'callback',{@changeSize,ch,-1});
uicontrol('parent',dest,'units','normalized',...
    'position',pv(3,.5,nRows-1.5,.5),'style','pushbutton','string','^',...
    'callback',{@changeSize,ch,1,sizeDecrease});





function showHide(varargin)
box = varargin{1};
pointCloud = varargin{3};
newVal = box.Value;
if newVal
    pointCloud.Visible = 'on';
else
    pointCloud.Visible = 'off';
end
SyncMainPanel

function changeColor(varargin)
global checkboxes swatches allAxChildren
pointCloud = varargin{3};
ind = varargin{4};
newCol = uisetcolor;
set(checkboxes{ind},'backgroundcolor',newCol);
% set(swatches{ind},'backgroundcolor',newCol);
set(pointCloud,'color',newCol)
cellfun(@(pl)set(pl{ind},'color',newCol),allAxChildren);
% cellfun(@(pl)cellfun(@(chil,onOff)set(chil,'visible',onOff),pl,newVisibleVals),allAxChildren)

function showHideAll(varargin)
global checkboxes lastState
thisState = cellfun(@(x)x.Value,checkboxes);

lines = varargin{3};
val = varargin{4};

if length(unique(thisState)) > 1 || isempty(lastState) % not currently showing/hiding all, so do that
    set(lines,'Visible',val);
    switch val
        case 'on'
            set([checkboxes{:}],'value',1);
        case 'off'
            set([checkboxes{:}],'value',0);
    end
else % currently showing/hiding all, so return to previous state
    for i = 1:length(lines)
    switch lastState(i)
        case 1
            set(lines(i),'Visible','on');
            set(checkboxes{i},'Value',1)
        case 0
            set(lines(i),'Visible','off');
            set(checkboxes{i},'Value',0)
    end
    end
end
lastState = thisState;
SyncMainPanel

function changeSize(varargin)
lines = varargin{3}; multiplier = varargin{4};
if length(varargin)>=5
    sizeDecrease = varargin{5};
else
    sizeDecrease = varargin{1};
end

currentSize = get(lines(1),'markerSize');
newSize = currentSize + 2*multiplier;
if newSize<=1
    newSize = 1;
    set(sizeDecrease,'enable','off')
else
    set(sizeDecrease,'enable','on')
end
set(lines,'markerSize',newSize);

function SyncMainPanel(varargin)
global checkboxes allAxChildren syncBox

newVisibleVals = repmat({'on'},size(checkboxes))';
if syncBox.Value
    % then we should sync the lines of the mini plots to the choices of the
    % checkbox
    choices = cellfun(@(x)x.Value,checkboxes);
    newVisibleVals(~logical(choices)) = {'off'};
end

cellfun(@(pl)cellfun(@(chil,onOff)set(chil,'visible',onOff),pl,newVisibleVals),allAxChildren)

function cutOnThis(varargin)
global checkboxes axInd
ckBoxes = checkboxes(end:-1:1); %want ordered from first to last to correspond with clusters, but don't wnat to change the global variable
xy = varargin{3};
values = logical(cellfun(@(x)get(x,'value'),ckBoxes));
if sum(values) > 1
    disp('Please have only one cluster class selected when you choose this button');
    return
elseif sum(values) == 1

thisClass = find(values);
else
    thisClass = 0;
end
%%
features = xy(axInd,:);
f = figure('units','normalized','position',[0.3902    0.0667    0.5027    0.8618]);
pv = makePosVecFunction(5.5,24);
ax(1) = axes('parent',f,'units','normalized','position',pv(1,19,1,1)); hold on;
ax(2) = axes('parent',f,'units','normalized','position',pv(1,19,2,1));hold on;
ax(3) = axes('parent',f,'units','normalized','position',pv(1,19,3,1));hold on;

ax(4) = axes('parent',f,'units','normalized','position',pv(1,7,5,2));hold on;

ax(5) = axes('parent',f,'units','normalized','position',pv(12,7,5,2));hold on;





waveClusFig = findobj('tag','wave_clus_figure');
handles = guidata(waveClusFig);
USER_DATA = get(handles.wave_clus_figure,'userdata');

inspk = USER_DATA{7};
classes = USER_DATA{6};
spikeTimes = USER_DATA{3};
waveforms = USER_DATA{2};
spikeAmplitudes = USER_DATA{2}(:,23);

feature1 = inspk(:,features(1));
feature2 = inspk(:,features(2));

colors = cellfun(@(x)get(x,'backgroundcolor'),ckBoxes,'uniformoutput',0);

for clust = 0:length(ckBoxes)
    theseSpikes = classes == clust;
    if clust > 0
        col = colors{clust};
    else
        col = .5*[1 1 1];
    end
    if sum(theseSpikes)>0
    theseLines(4+clust) = plot(ax(1),spikeTimes(theseSpikes),spikeAmplitudes(theseSpikes),'.','color',col);
    end
    if clust==thisClass
        theseLines(1) = plot(ax(2),spikeTimes(theseSpikes),feature1(theseSpikes),'.','color',col);
        theseLines(2) = plot(ax(3),spikeTimes(theseSpikes),feature2(theseSpikes),'.','color',col);
        theseLines(3) = plot(ax(4),feature2(theseSpikes),feature1(theseSpikes),'.','color',col);
        plot(ax(5),waveforms(randsample(find(theseSpikes),min(sum(theseSpikes),500)),:)');
    end
end
set(ax(1:3),'xlim',[0 max(spikeTimes)]);
linkaxes(ax(1:3),'x');

features = [spikeAmplitudes,feature1,feature2]';
theseSpikes = classes == thisClass;

keepLast = uicontrol('parent',f,'units','normalized',...
    'position',pv(19,2.5,5.5,.5),'style','pushbutton',...
    'string','Keep Last','callback',{@keepRevert},'visible','off');
revertLast = uicontrol('parent',f,'units','normalized',...
    'position',pv(22,2.5,5.5,.5),'style','pushbutton',...
    'string','Revert Last','callback',{@keepRevert},'visible','off');
saveButton = uicontrol('parent',f,'units','normalized',...
    'position',pv(1,2.5,5.5,.5),'style','pushbutton',...
    'string','Apply in Main Window','callback',{@saveChanges,f,theseSpikes,'remove'},'visible','off');
compareWaveformsButton = uicontrol('parent',f,'units','normalized',...
    'position',pv(5,2.5,5.5,.5),'style','pushbutton',...
    'string','Compare Waveforms','callback',{@compareWaveforms,f,theseSpikes},'visible','off');
saveButton(2) = uicontrol('parent',f,'units','normalized',...
    'position',pv(3,2.5,5.5,.5),'style','pushbutton',...
    'string','Make New Cluster','callback',{@saveChanges,f,theseSpikes,'new'},'visible','off');

saveButton(4) = uicontrol('parent',f,'units','normalized',...
    'position',pv(9,2.5,5.5,.5),'style','pushbutton',...
    'string','Split','callback',{@saveChanges,f,theseSpikes,'split'},'visible','off');
removeButton(1) = uicontrol('parent',f,'units','normalized',...
    'position',pv(20,4,1,.5),'style','pushbutton',...
    'string','Mark to Remove');
removeButton(2) = uicontrol('parent',f,'units','normalized',...
    'position',pv(20,4,2,.5),'style','pushbutton',...
    'string','Mark to Remove');
removeButton(3) = uicontrol('parent',f,'units','normalized',...
    'position',pv(20,4,3,.5),'style','pushbutton',...
    'string','Mark to Remove');
removeButton(4) = uicontrol('parent',f,'units','normalized',...
    'position',pv(8,4,4,.5),'style','pushbutton',...
    'string','Mark to Remove');
removeButton(5) = uicontrol('parent',f,'units','normalized',...
    'position',pv(20,4,4,.5),'style','pushbutton',...
    'string','Mark to Remove');

saveButton(3) = uicontrol('parent',f,'units','normalized',...
    'position',pv(7,2.5,5.5,.5),'style','pushbutton',...
    'string','Keep this polygon for splitting','callback',...
    {@addPolygon,f,theseSpikes,removeButton},'visible','off');

sizeDecrease = uicontrol('parent',f,'units','normalized',...
    'position',pv(8,1,5,.25),'style','pushbutton','string','v',...
    'callback',{@changeSize,theseLines,-1});
uicontrol('parent',f,'units','normalized',...
    'position',pv(8,1,4.75,.25),'style','pushbutton','string','^',...
    'callback',{@changeSize,theseLines,1,sizeDecrease});

arrayfun(@(b,i)set(b,'callback',{@markToRemove,ax,spikeTimes,features,i,f,...
    theseSpikes,waveforms,[keepLast,revertLast,saveButton,compareWaveformsButton],removeButton}),...
    removeButton,1:5,'uniformoutput',0);
set(keepLast,'callback',{@keepRevert,'keep',keepLast,revertLast,removeButton,f})
set(revertLast,'callback',{@keepRevert,'revert',keepLast,revertLast,removeButton,f})
    

function markToRemove(varargin)
ax = varargin{3};spikeTimes = varargin{4};
features = varargin{5}; ind = varargin{6}; 
f = varargin{7};theseSpikes=varargin{8}';
waveforms = varargin{9};

switch ind
    case {1,2,3}
in = UIInPolygon(spikeTimes,features(ind,:));
    case 4
  in = UIInPolygon(features(3,:),features(2,:));
    case 5
        in = UIInPolygon(repmat(1:size(waveforms,2),size(waveforms,1),1),waveforms);
    in = any(in,2)';
end
if sum(theseSpikes & in)
    for i = 1:size(features,1)
        hold(ax(i),'on');
        lines(i) = plot(ax(i),spikeTimes(theseSpikes & in),features(i,theseSpikes & in),'k.','markersize',9);
    end
    hold(ax(4),'on');
    lines(4) = plot(ax(4),features(3,theseSpikes & in),features(2,theseSpikes & in),'k.','markersize',9);
    hold(ax(5),'on'); subset = randsample(find(theseSpikes & in),min(sum(theseSpikes & in),500));
    newlines = plot(ax(5),waveforms(subset,:)','k'); newlines = newlines';
else
    return;
end
h = guidata(f);
if isempty(h)
    h.toRemove = in;
    h.lines = {[lines newlines]};
else
    h.toRemove = [h.toRemove;in];
    h.lines{end+1} = [lines newlines];
end

guidata(f,h);
set(varargin{10},'visible','on');
set(varargin{11},'visible','off');

function keepRevert(varargin)
switch varargin{3}
    case 'keep'
        % nothing to do
    case 'revert'
        h = guidata(varargin{7});
        h.toRemove(end,:) = [];
        delete(h.lines{end})
        h.lines(end) = [];
        guidata(varargin{7},h)
end
set([varargin{4:5}],'visible','off');
set(varargin{6},'visible','on');
1;

function saveChanges(varargin)
h = guidata(varargin{3});
toRemove = any(h.toRemove,1) & varargin{4}';

waveClusFig = findobj('tag','wave_clus_figure');
handles = guidata(waveClusFig);
USER_DATA = get(handles.wave_clus_figure,'userdata');
handles.force = 0;
handles.merge = 0;
handles.undo = 1;
handles.setclus = 0;
handles.reject = 0;
clustering_results_bk = USER_DATA{11};
handles.minclus = clustering_results_bk(1,5);
classes = USER_DATA{6};

currentClass = unique(classes(toRemove));
assert(length(currentClass)==1,'It looks like you''re cutting on more than one class. How did this happen?')

switch varargin{5}
    case 'new'
        classes(toRemove) = max(classes)+1;
    case 'remove'
        classes(toRemove) = 0;
    case 'split'
        maxClass = max(classes);
        nClusts = size(h.toRemove,1);
        for k = 1:nClusts
            thisClass = maxClass+k;
            inThis = h.toRemove(k,:) & h.theseSpikes;
            classes(inThis) = thisClass;
        end
end

USER_DATA{6} = classes;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
if strcmp(varargin{5},'split')
    rejectAndForce(currentClass);
else
fprintf('Finished!\n')
end
close(varargin{3})

function addPolygon(varargin)
h = guidata(varargin{3});
if ~isfield(h,'theseSpikes')
    h.theseSpikes = varargin{4}';
end
set(varargin{5},'visible','on')
guidata(varargin{3},h);

function compareWaveforms(varargin)
h = guidata(varargin{3});
toRemove = any(h.toRemove,1) & varargin{4}';

waveClusFig = findobj('tag','wave_clus_figure');
handles = guidata(waveClusFig);
USER_DATA = get(handles.wave_clus_figure,'userdata');
waveforms = USER_DATA{2};

kept = waveforms(varargin{4}' & ~toRemove,:); nKept = size(kept,1);
rejected = waveforms(toRemove,:); nRejected = size(rejected,1);
if nKept > 8000
    keptInds = randsample(nKept,8000);
    kept = kept(keptInds,:);
end
if nRejected > 8000
    rejInds = randsample(nRejected,8000);
    rejected = rejected(rejInds,:);
end
figure; 
ax(1) = subplot(311); hold on; plot(kept','b'); plot(rejected','r'); 
ax(2) = subplot(312); title(sprintf('kept (%d)',nKept)); plot(kept'); 
ax(3) = subplot(313); title(sprintf('rejected (%d)', nRejected')); plot(rejected')
linkaxes(ax)