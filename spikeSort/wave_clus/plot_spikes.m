function plot_spikes(handles)
USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};
if isempty(par)
    par = handles.par;
end
spikes = USER_DATA{2};
spk_times = USER_DATA{3};
% clu = USER_DATA{4};
classes = USER_DATA{6};
classes = classes(:)';
class_bkup = USER_DATA{9};
% class_bkup = class_bkup;
inspk = USER_DATA{7};
temp = USER_DATA{8};
ls = size(spikes, 2);
par.to_plot_std = 1;                % # of std from mean to plot

merge = handles.merge;
minclus = handles.minclus;
clustering_results = USER_DATA{10};

% Closes aux figures
h_figs = get(0, 'children');
h_fig  = findobj(h_figs, 'tag', 'wave_clus_figure');

% EM: It's inefficient to close all of these if you're just going to open
% them again shortly. Set to visible off instead.
% h_fig1 = findobj(h_figs,'tag','wave_clus_aux');
% h_fig2= findobj(h_figs,'tag','wave_clus_aux1');
% h_fig3= findobj(h_figs,'tag','wave_clus_aux2');
% h_fig4= findobj(h_figs,'tag','wave_clus_aux3');
% h_fig5= findobj(h_figs,'tag','wave_clus_aux4');
% h_fig6= findobj(h_figs,'tag','wave_clus_aux5');
% close(h_fig1); close(h_fig2); close(h_fig3); close(h_fig4); close(h_fig5); close(h_fig6);

aux_figs = cellfun(@(x)findobj(h_figs, 'tag', ['wave_clus_aux',x]),...
    {'','1','2','3','4','5'}, 'uniformoutput', 0);
for m=1:length(aux_figs)
    if ~isempty(aux_figs{m})
        set(0,'currentFigure',aux_figs{m});
        set(aux_figs{m},'visible','off');
        ch = get(aux_figs{m},'children');
        for k = 1:length(ch)
            cla(ch(k),'reset');
        end
        arrayfun(@(x)cla(x,'reset'),ch);
    end
end

% Extract spike features if needed
if get(handles.spike_shapes_button,'value') ==0
    if isempty(inspk) || (length(inspk)~=size(spikes,1))
        [inspk] = wave_features_wc(spikes, handles);
        USER_DATA{7} = inspk;
    end
end

% Defines nclusters
cluster_sizes=[];
cluster_sizes_bkup=[];
ifixflag=zeros(1, par.max_clus);
for i=1:par.max_clus
    cluster_sizes = [cluster_sizes sum(classes==i)];
    cluster_sizes_bkcup = [cluster_sizes_bkup sum(class_bkup==i)];
end

% Classes should be consecutive numbers
i=1;
while i<=min(max(classes),par.max_clus)
    if isempty(classes(classes==i))
        % This code can get stuck in an infinite loop if there are no
        % clusters between i and par.max_clus... So I replace it with the
        % code below:
        %         for k=i+1:par.max_clus
        %             classes(classes==k)=k-1;
        %         end
        classes(classes>=i) = classes(classes>=i)-1;
    else
        i=i+1;
    end
end
i=1;
while i<=min(max(class_bkup),par.max_clus)
    if isempty(class_bkup(class_bkup==i))
%         for k=i+1:par.max_clus
%             class_bkup(class_bkup==k)=k-1;
%         end
        class_bkup(class_bkup>=i) = class_bkup(class_bkup>=i)-1;
    else
        i=i+1;
    end
end

nclusters_bkup = length(find(cluster_sizes(:) >= par.min_clus));
class_bkup(class_bkup > nclusters_bkup)=0;

if handles.setclus == 0 && handles.undo==0 && handles.merge==0 && handles.force==0
    sizemin_clus = par.min_clus;
else
    sizemin_clus = 1;
end
nclusters = length(find(cluster_sizes(:) >= sizemin_clus));

% Get fixed clusters
fix_class2 = [];
nfix_class = [];
haveResetClustersAlready = 0;

for m=1:3
    if get(handles.(['fix',num2str(m),'_button']),'value') ==1
        nclusters = nclusters +1;
        fix_class = USER_DATA{19+m}';
        if ~haveResetClustersAlready
            classes(classes==nclusters)=0;
            haveResetClustersAlready = 1;
        end
        classes(fix_class) = nclusters;
        ifixflag(nclusters)=1;
        fix_class2 = [fix_class2 fix_class];
        nfix_class = [nfix_class m];
    end
end

% Get fixed clusters from aux figures
for i=4:par.max_clus
    if isfield(par, ['fix', num2str(i)])
        fixx = par.(['fix', num2str(i)]);
        if fixx == 1
            nclusters = nclusters + 1;
            fix_class = USER_DATA{22+i-3}';
            if ~haveResetClustersAlready
                classes(classes==nclusters)=0;
                haveResetClustersAlready = 1;
            end
            classes(fix_class)  = nclusters;
            ifixflag(nclusters) = 1;
            
            fix_class2 = [fix_class2 fix_class];
            nfix_class = [nfix_class i];
        end
    end
end

% Merge operations
mtemp = 0;
if handles.merge == 1 && ~isempty(nfix_class)
    imerge = find(clustering_results(:,2)==nfix_class(1)); % index for the original temperature that will represent all the fixed classes
    mtemp = clustering_results(imerge(1),3); % temperature that represents all the fixed classes
    classes(fix_class2) = nfix_class(1); % labels all the fixed classes with the new number
end

% Defines classes
clustered = [];
cont=0;
classDefs = cell(nclusters,1);
for i=1:nclusters
    class_temp = find(classes==i);
    %     eval(['class_temp = find(classes==' num2str(i) ');'])
    if ((ifixflag(i)==1) && (~isempty(class_temp)))
        ifixflagc = 1;
    else
        ifixflagc = 0;
    end
    if ((length(class_temp) >= sizemin_clus) || (ifixflagc == 1))
        cont=cont+1;
        %EM: Ugh. Never hard code numbers into variable names. Instead
        %we'll make classDefs a cell array such that classDefs{1} is what
        %class1 used to be.
        classDefs{cont} = class_temp;
        clustered = [clustered classDefs{cont}];
        %         eval(['class' num2str(cont) '= class_temp;'])
        %         eval(['clustered = [clustered class' num2str(cont) '];'])
    end
end
nclusters = cont;
class0 = setdiff( 1:size(spikes,1), sort(clustered) );

% Redefines classes
classes = zeros(size(spikes,1),1);
for i = 1:nclusters%+1 EM, don't need the +1 because we don't need to start at 0 since class0 already has 0s everywhere.
    % if ~ (isempty(class0) & i==1)
    classes(classDefs{i}) = i;
    % eval(['classes(class' num2str(i-1) ') = ' num2str(i-1) ';']);
    % end
end
classDefs = [{class0};classDefs];
% Saves new classes
USER_DATA{6} = classes;
USER_DATA{9} = class_bkup;

% updates 'clustering_results_bk'
clustering_results = [clustering_results; zeros(size(classes,1)-size(clustering_results,1),5)];
clustering_results_bk = clustering_results;

% Forcing
if handles.force==1
    for i=1:max(classes)
        ind = find(clustering_results(:,2)==i); % get index of GUI class
        oclass = clustering_results(ind(1),4); % get original class
        otemp = clustering_results(ind(1),3); % get original temperature
        ind2 = find(classes==i); % get index of forced class
        clustering_results(ind2,2) = i; % update GUI class with forced class
        clustering_results(ind2,3) = otemp; % update original temperatures with forced class
        clustering_results(ind2,4) = oclass; % update original class with forced class
    end
end

% new temperature when merge
if handles.merge == 1 && ~isempty(nfix_class)
    clustering_results(fix_class2,3) = mtemp;
    clustering_results(fix_class2,4) = clustering_results(imerge(1),4);
end
clustering_results(:,1) = temp; % GUI temperature
clustering_results(:,5) = minclus; % GUI minimum cluster

% Saves new classes and keep fixed classes in 'clustering_results'.
% Keep the original temperature and cluster number in the fixed spikes.
% The temperature of the non-fixed spikes will be
% the GUI temperature (temp) and cluster number will be
% the GUI cluster number (classes)
if ~isempty(fix_class2) && handles.merge==0 && handles.undo==0 && handles.reject==0 && handles.force==0
    % selects the index of the non-fixed spikes
    % since those are the ones which are going to be updated
    ind_non_fix = 1:length(classes);
    ind_non_fix(fix_class2) = [];
    clustering_results(ind_non_fix,4) = classes(ind_non_fix); % classes of the non-fixed spikes in the original clusters column
    clustering_results(ind_non_fix,3) = temp; % temperature of the non-fixed spikes in the original temperature column
end

% update new classes
clustering_results(:,2) = classes;
% If there are no fix and rejected clusters and undo operations,
% original classes are the same as current classes
if isempty(fix_class2) && handles.reject==0 && handles.undo==0 && handles.merge==0 && handles.force==0
    clustering_results(:,4) = clustering_results(:,2); % clusters
    clustering_results(:,3) = temp; % temperatures
end

% reject spikes during times that have been excluded:
ts = USER_DATA{3}*1e-3; %ts now in seconds

if length(USER_DATA)>=19 && ~isempty(USER_DATA{19})
    
    f = eval(USER_DATA{19});
    rejectInds = f(ts);
    classes(rejectInds) = 0;
    USER_DATA{6} = classes;
    classDefs = arrayfun(@(x)find(classes==x),0:(length(classDefs)-1), 'uniformoutput', 0);
    nowEmpty = cellfun(@(x)isempty(x),classDefs);
    oldClusterNums = 0:length(classDefs)-1;
    classDefs(nowEmpty) = [];
    oldClusterNums(nowEmpty) = [];
    newClusterNums = 0:length(classDefs)-1;
    if ~isequal(oldClusterNums,newClusterNums)
        for jj = 1:length(oldClusterNums)
            classes(classes==oldClusterNums(jj)) = newClusterNums(jj);
        end
    end
end
nclusters = max(classes);

% Updates clustering_results and clustering_results_bk in USER_DATA
USER_DATA{10} = clustering_results;
USER_DATA{11} = clustering_results_bk;
% set(handles.wave_clus_figure,'userdata',USER_DATA)

for i=20:55
    USER_DATA{i} = [];
end
set(handles.wave_clus_figure,'userdata',USER_DATA)

% Clear plots
for i=1:4
    cla(handles.(['spikes',num2str(i-1)]),'reset');
    cla(handles.(['isi',num2str(i-1)]),'reset');
end
cla(handles.projections,'reset');


% Plot clusters
ylimit = [];
colors = ['k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'k' 'b' 'r' 'g' 'c' 'm' 'y' 'b' 'r' 'g' 'c' 'm' 'y' 'b'];

for i = 1:nclusters+1
    if ~ (isempty(class0) && i==1)
        %PLOTS SPIKES OR PROJECTIONS
        
        hold(handles.projections,'on')
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
        
        if i < 5
            ax = handles.(['spikes', num2str(i-1)]);
            hold(ax,'on');
            
            av = mean(spikes(classDefs{i},:));
            avup = av + par.to_plot_std * std(spikes(classDefs{i},:));
            avdw = av - par.to_plot_std * std(spikes(classDefs{i},:));
            
            if get(handles.plot_all_button,'value') ==1
                
                plot(ax,spikes(classDefs{i}(permut),:)','color',colors(i) );
                if i==1
                    plot(ax,1:ls,av,'c','linewidth',2)
                    plot(ax,1:ls,avup,'c','linewidth',.5)
                    plot(ax,1:ls,avdw,'c','linewidth',.5)
                else
                    plot(ax,1:ls,av,'k','linewidth',2);
                    plot(ax,1:ls,avup,1:ls,avdw,'color',[.4 .4 .4],'linewidth',.5)
                end
            else
                plot(ax,1:ls,av,'color',colors(i),'linewidth',2)
                plot(ax,1:ls,avup,1:ls,avdw,'color',[.65 .65 .65],'linewidth',.5)
            end
            xlim(ax,[1 ls])
            
            if i>1; ylimit = [ylimit; get(ax, 'ylim')]; end
            nSpikes = length(classDefs{i});
            title(ax, ['Cluster ' num2str(i-1) ':  nSpikes = ' num2str(nSpikes)], 'Fontweight', 'bold');
            
            isiAx = handles.(['isi' num2str(i-1)]);
            times{i} = diff(spk_times(classDefs{i}));
            % Calculates # ISIs < 3ms
            bin_step_temp = 1;
            [N,X]=hist(times{i}, 0:bin_step_temp:par.(['nbins', num2str(i-1)]));
            multi_isi= sum(N(1:3));
            pct_violations = multi_isi/length(times{i});
            % Builds and plots the histogram
            bar(isiAx, X(1:end-1), N(1:end-1))
            xlim(isiAx, [0 par.(['nbins' num2str(i-1)])])
            %The following line generates an error in Matlab 7.3
            %eval(['set(get(gca,''children''),''FaceColor'',''' colors(i) ''',''EdgeColor'',''' colors(i) ''',''Linewidth'',0.01);']);
            title(isiAx, [num2str(multi_isi) ' in < 3ms (', num2str(pct_violations*100), '%)'])
            xlabel(isiAx,'ISI (ms)');
        else
            par.axes_nr = i;
            par.ylimit = ylimit;
            par.class_to_plot = classDefs{i};
            par.plot_all_button = get(handles.plot_all_button, 'value');
            USER_DATA{1} = par;
            set(handles.wave_clus_figure, 'userdata', USER_DATA)
            if i < 10
                wave_clus_aux
            elseif i < 15
                wave_clus_aux1
            elseif i < 20
                wave_clus_aux2
            elseif i < 25
                wave_clus_aux3
            elseif i < 30
                wave_clus_aux4
            else
                wave_clus_aux5
            end
            %--------------------------------------------------------------
        end
    end
end

%Resize axis
if ~strcmp(char(handles.datatype), 'Sc data') && ~strcmp(char(handles.datatype), 'Sc data (pre-clustered)')
    if ~isempty(ylimit)
        ymin = min(ylimit(:,1));
        ymax = max(ylimit(:,2));
        for i=1:3
            eval(['axes(handles.spikes' num2str(i) '); ylim([ymin ymax])'])
        end
    end
end

peakPlot(handles)
% sound(sin(4400*(1:30000)),15000)

