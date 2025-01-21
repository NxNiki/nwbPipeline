function plot_spikes_aux(handles)
USER_DATA = get(handles.wave_clus_aux,'userdata');
par = USER_DATA{1};
spikes = USER_DATA{2};
spk_times = USER_DATA{3};
inspk = USER_DATA{7};
ls = size(spikes,2);
par.to_plot_std = 1;                % # of std from mean to plot
if ~isfield(par,'axes_nr')
    axes_nr = 5;
else
    axes_nr = par.axes_nr;
end
if ~isfield(par,'ylimit')
    ylimit = [-60 80; -60 60; -50 40];
else
    ylimit = par.ylimit;
end
class_to_plot = par.class_to_plot;
max_spikes = min(par.max_spikes, length(class_to_plot));
sup_spikes = length(class_to_plot);

% Plot clusters
colors = ['k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];
axes(handles.(['spikes' num2str(axes_nr-1)]));

cla reset
hold on
av   = mean(spikes(class_to_plot,:));
avup = av + par.to_plot_std * std(spikes(class_to_plot,:));
avdw = av - par.to_plot_std * std(spikes(class_to_plot,:));
if par.plot_all_button ==1
    permut=randperm(sup_spikes);
    plot(spikes(class_to_plot(permut(1:max_spikes)),:)','color',colors(axes_nr));
    plot(1:ls,av,'k','linewidth',2);
    plot(1:ls,avup,1:ls,avdw,'color',[.4 .4 .4],'linewidth',.5)
else
    plot(1:ls,av,'color',colors(axes_nr),'linewidth',2)
    plot(1:ls,avup,1:ls,avdw,'color',[.65 .65 .65],'linewidth',.5)
end
xlim([1 ls])
aux = num2str(length(class_to_plot));
title(['Cluster ' num2str(axes_nr-1) ':  # ', aux], 'Fontweight', 'bold');

axes(handles.(['isi' num2str(axes_nr-1)]));

times = diff(spk_times(class_to_plot));
% Calculates # ISIs < 3ms
bin_step_temp = 1;
[N,X]=hist(times, 0: bin_step_temp: par.(['nbins' num2str(axes_nr-1)]));
multi_isi= sum(N(1:3));
% Builds and plots the histogram
[N,X]=hist(times, 0: par.(['bin_step' num2str(axes_nr-1)]): par.(['nbins' num2str(axes_nr-1)]));
bar(X(1:end-1),N(1:end-1))
xlim([0, par.(['nbins' num2str(axes_nr-1)])]);

%eval(['set(get(gca,''children''),''facecolor'',''' colors(axes_nr) ''',''edgecolor'',''' colors(axes_nr) ''',''linewidth'',0.01);']);
title([num2str(multi_isi) ' in < 3ms'])
xlabel('ISI (ms)');

%Resize axis
ymin = min(ylimit(:,1));
ymax = max(ylimit(:,2));
axes(handles.(['spikes' num2str(axes_nr-1)]));
ylim([ymin ymax]);

set(handles.fix4_button,'value',0);
set(handles.fix5_button,'value',0);
set(handles.fix6_button,'value',0);
set(handles.fix7_button,'value',0);
set(handles.fix8_button,'value',0);

mainHandle = findobj('tag', 'wave_clus_figure');
mainHandles = guidata(mainHandle);

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
