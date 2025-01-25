function plot_spikes_aux(handles, mainHandles, par, axesIdx, spikes, spk_times)
% Todo: use plot_spikes to aux UIs.
    
clusterIdx = handles.clusterIdx; % define in plot_spikes.
plotLabelIdx = handles.plotLabelIdx;

ls = size(spikes, 2);
to_plot_std = 1;                % # of std from mean to plot

if ~isfield(par,'ylimit')
    ylimit = [-60 80; -60 60; -50 40];
else
    ylimit = par.ylimit;
end

sup_spikes = length(spk_times);
max_spikes = min(par.max_spikes, sup_spikes);

colors = ['k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];
% Plot clusters
axes(handles.(['spikes' num2str(plotLabelIdx(axesIdx))]));
%Resize axis
ymin = min(ylimit(:,1));
ymax = max(ylimit(:,2));
ylim([ymin ymax]);

cla reset
hold on
av   = mean(spikes);
avup = av + to_plot_std * std(spikes);
avdw = av - to_plot_std * std(spikes);

if par.plot_all_button ==1
    permut=randperm(sup_spikes);
    plot(spikes(permut(1:max_spikes),:)','color', colors(clusterIdx(axesIdx)));
    plot(1:ls,av,'k','linewidth',2);
    plot(1:ls,avup,1:ls,avdw,'color',[.4 .4 .4],'linewidth',.5)
else
    plot(1:ls,av,'color', colors(axes_nr), 'linewidth',2)
    plot(1:ls,avup,1:ls,avdw,'color',[.65 .65 .65],'linewidth',.5)
end

xlim([1 ls])
aux = num2str(sup_spikes);
title(['Cluster ' num2str(clusterIdx(axesIdx)) ':  # ', aux], 'Fontweight', 'bold');

axes(handles.(['isi' num2str(plotLabelIdx(axesIdx))]));

times = diff(spk_times);
% Calculates # ISIs < 3ms
bin_step_temp = 1;

nbins = mainHandles.(sprintf('nbins%d', clusterIdx(axesIdx)));
bin_step = mainHandles.(sprintf('bin_step%d', clusterIdx(axesIdx)));

[N,X]=hist(times, 0: bin_step_temp: nbins);
multi_isi= sum(N(1:3));
% Builds and plots the histogram
[N,X]=hist(times, 0: bin_step: nbins);
bar(X(1:end-1),N(1:end-1))
xlim([0, nbins]);

%eval(['set(get(gca,''children''),''facecolor'',''' colors(axes_nr) ''',''edgecolor'',''' colors(axes_nr) ''',''linewidth'',0.01);']);
title([num2str(multi_isi) ' in < 3ms'])
xlabel('ISI (ms)');

for i = 1:5
    % Find the desired radio button handle
    clusterIdx = 3 + i;
    if clusterIdx > length(mainHandles.clusterUnitType)
        break;
    end
    
    % Find the uibuttongroup handle for unit type
    idx = mainHandles.clusterUnitType(clusterIdx) + 44 + (i-1)*3;
    rb = handles.(sprintf('radiobutton%d', idx));
    set(handles.(sprintf('uibuttongroup%d', i)), 'SelectedObject', rb);
end
