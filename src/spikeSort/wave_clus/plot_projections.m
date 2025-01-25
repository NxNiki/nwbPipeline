plot_projection(handles, spikes, classDefs)

% Todo: separate this from plot_spikes.

for i = 1:nclusters+1
    if ~ (isempty(class0) && i==1)
        %PLOTS SPIKES OR PROJECTIONS

        hold(handles.projections, 'on')
        max_spikes=min(length(classDefs{i}), par.max_spikes);
        sup_spikes=length(classDefs{i});
        permut = randperm(sup_spikes); permut = permut(1:max_spikes);
%         if get(handles.spike_shapes_button,'value') ==1 && get(handles.plot_all_button,'value') ==1
%             plot(handles.projections,spikes(classDefs{i}(permut),:)',colors(i));
%             xlim([1 ls])
%     else %this was originally an elseif, but I want this to be true all
%     the time, so I commented out the above.
        if get(handles.spike_shapes_button, 'value') ==1
            av = mean(spikes(classDefs{i}, :));
            plot(handles.projections, 1:ls, av, 'color', colors(i), 'linewidth', 2);
            xlim([1 ls])
        else
            plot(inspk(classDefs{i}, 1), inspk(classDefs{i}, 2), '.', 'color', colors(i) , 'markersize', .5);
        end
    end
end