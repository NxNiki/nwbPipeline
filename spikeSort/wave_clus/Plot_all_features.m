function Plot_all_features(handles)
% function Plot_all_features(handles)

USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
inspk = USER_DATA{7};
classes = USER_DATA{6};

colors = ['b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];

f1 = findobj('name','ProjectionsPlot');
if isempty(f1)
f1 = figure('name','ProjectionsPlot');
else
    ch = get(f1,'children');
    delete(ch);
end
nclasses = max(classes);
inputs = min(size(inspk,2),12);
for i=1:inputs
    for j=i+1:inputs
        ax(i,j) = subplot2(inputs, inputs,i,j,'borderpct',.0001,'parent',f1);
%         subplot(inputs,inputs,(i-1)*inputs+j)
        hold on
        for k=1:nclasses
            class_aux = find(classes==k);
            max_spikes = min(par.max_spikes,length(class_aux));
            inds = randsample(class_aux,max_spikes);
            plot(inspk(inds,i),inspk(inds,j),['.' colors(k)],'markersize',.5)
%             plot(inspk(class_aux(1:max_spikes),i),inspk(class_aux(1:max_spikes),j),...
%                 ['.' colors(k)],'markersize',.5)
            axis off
        end
    end
end

pv = makePosVecFunction(2,2,.01,.01,.025);
f = uipanel('parent',f1,'units','normalized','position',pv(1,1,2,1));
syncBox = uicontrol('parent',f1,'units','normalized',...
    'position',pv(2,.25,2,.15),'style','checkbox','string','Sync','value',1);
cutOnThisButton = uicontrol('parent',f1,'units','normalized',...
    'position',pv(1,.25,1,.15),'style','pushbutton','string','cutOnTheseFeatures');
exploreProjections(f,ax,syncBox,cutOnThisButton);
