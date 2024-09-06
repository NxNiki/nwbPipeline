function mark_clusters_temperature_diagram(handles, tree, clustering_results, newData)
% MARK CLUSTERS IN TEMPERATURE DIAGRAM
% EM: added 'newData' as a var. When we're loading new data, clear the plot
% and make the diagram, but no need to do so for data that's already been
% loaded.

handles.par.min.clus = clustering_results(1,5);
temperature = tree(clustering_results(1,1)+1,2);

if ~exist('newData','var')||isempty(newData)
    newData = 0;
end

% creates cluster-temperature vector to plot in the temperature diagram
nclasses = max(clustering_results(clustering_results(:,2)<1000, 2));
if nclasses == 0
    return
end

clustering_results(:, 2) = shrinkClassIndex(clustering_results(:, 2));
clustering_results(:, 4) = shrinkClassIndex(clustering_results(:, 4));

% if length(unique(clustering_results(:,2))) < nclasses
% i=1;
% while i<= nclasses
%     if sum(clustering_results(:,2)==i)==0
%         indsToSubtract = clustering_results(:,2)>i;
%         clustering_results(indsToSubtract,[2 4]) = clustering_results(indsToSubtract,[2 4]) - 1;
%         nclasses = nclasses-1;
%     else
%         i=i+1;
%     end
% end
% end

for i=1:nclasses
    ind = find(clustering_results(:,2)==i);
    classgui_plot(i) = clustering_results(ind(1),2);
    class_plot(i) = clustering_results(ind(1),4);
    temp_plot(i) = clustering_results(ind(1),3);
end


% colors = ['b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];
colors = ['b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];

% draw temperature diagram and mark clusters
handles.par.num_temp = min(handles.par.num_temp,size(tree,1));
if newData
cla(handles.temperature_plot);
end
hold(handles.temperature_plot,'on')
switch handles.par.temp_plot
    case 'lin'
        % draw diagram
        plot(handles.temperature_plot,[handles.par.mintemp handles.par.maxtemp-handles.par.tempstep],[handles.par.min.clus2 handles.par.min.clus2],'k:',...
            handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
            tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
        % mark clusters
        hold on
        for i=1:length(class_plot)
            tree_clus = tree(temp_plot(i),4+class_plot(i));
            tree_temp = tree(temp_plot(i)+1,2);
            plot(handles.temperature_plot,tree_temp,tree_clus,'.','color',num2str(colors(classgui_plot(i))),'MarkerSize',20);
            % text(tree_temp,tree_clus,num2str(classgui_plot(i)));
        end
        hold off

    case 'log'
        if newData
        % draw diagram
         semilogy([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
            [handles.par.min.clus handles.par.min.clus],'k:',...
            handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
            tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:',...
            'parent',handles.temperature_plot)
        set(handles.temperature_plot,'yscale','log')
        end
        % mark clusters
        hold on
        for i=1:length(class_plot)
            try
            tree_clus = tree(temp_plot(i),4+class_plot(i));
            tree_temp = tree(temp_plot(i)+1,2);
            semilogy(tree_temp,tree_clus,'.','color',num2str(colors(classgui_plot(i))),...
                'MarkerSize',20,'parent',handles.temperature_plot);
            % text(tree_temp,tree_clus,num2str(classgui_plot(i)));
            end
        end
        hold off
end
xlim(handles.temperature_plot,[0 handles.par.maxtemp])
xlabel('Temperature');
if strcmp(handles.par.temp_plot, 'log')
    set(get(handles.temperature_plot,'ylabel'),'vertical','Cap');
else
    set(get(handles.temperature_plot,'ylabel'),'vertical','Baseline');
end
ylabel('Clusters size');
handles.setclus = 0;
