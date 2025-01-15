function [cluster_class, tree, clu, handles] = readData_ASCIISpikePreClustered(filename, pathname, handles)
% This function read *_spikes.mat file with corresponding times_*.mat,

% As wave_clus also saves result as times_*.mat file. We will check
% variables in times_*.mat to load spikes accordingly. This makes it
% inconvenient to redo manual spike clustering. Consider use new name for
% manual spike clustering in the future.


handles.par = set_joint_parameters_CSC(filename); %EM: Replaced the default wave_clus parameters with those that we've been using

% HISTOGRAM PARAMETERS
for i=1:handles.par.max_clus + 1
    handles.par.(['nbins' num2str(i-1)]) = 100;  % # of bins for the ISI histograms
    handles.par.(['bin_step' num2str(i-1)]) = 1;  % percentage number of bins to plot
end

% Sets to zero fix buttons from aux figures
for i=4:handles.par.max_clus
    handles.par.(['fix' num2str(i)]) = 0;
end

try % will fail on initial call, but not when data is being loaded?
    handles.par.filename = filename;
    handles.par.pathname = pathname;
end

USER_DATA = get(handles.wave_clus_figure, 'userdata');
USER_DATA{1} = handles.par;
set(handles.wave_clus_figure, 'userdata', USER_DATA);
set(handles.min_clus_edit, 'string', num2str(handles.par.min_clus));
% axes(handles.cont_data); EM: removed call to axes.
cla(handles.cont_data);

%Load spikes and parameters
spikeFile = fullfile(pathname, filename);
spikeFileObj = matfile(spikeFile, "Writable", true);

filename = strrep(filename, '_spikes', '');
timesFile = fullfile(pathname, ['times_', filename]);
if ~exist(timesFile, 'file')
    warning([timesFile, ' does not exist. Move on...'])
    [cluster_class, tree, clu] = deal([]);
    return
end

timesFileObj = matfile(timesFile);
cluster_class = timesFileObj.cluster_class;
manualTimesFile = fullfile(pathname, ['times_manual_' filename]);

handles.clusterUnitType = ones(1, length(unique(cluster_class(:, 1)))-1); % default is 1: single unit. other options 2: multi unit, 3: noise unit.

if exist(manualTimesFile, 'file')
    message = 'This spike file has been manually sorted, do you want to load the manually sorted result?';
    title = 'Spikes manually sorted already!';
    option1 = 'Yes';
    option2 = 'No';

    % Create the dialog box
    choice = questdlg(message, title, option1, option2, option1);
    if strcmp(choice, option1)
        manualTimesFileObj = matfile(manualTimesFile);
        cluster_class = manualTimesFileObj.cluster_class;
        if ismember('temp', who(manualTimesFileObj))
            USER_DATA{8} = manualTimesFileObj.temp;
        end
    end
end

spikeTimestamps=cluster_class(:, 2)'; % timestamps of spikes; gets loaded in line above.
numSpikes = length(spikeTimestamps);

spikeFileVars = who(spikeFileObj);
timesFileVars = who(timesFileObj);
if ismember('clu', spikeFileVars) && ismember('tree', spikeFileVars)
    clu = spikeFileObj.clu;
    tree = spikeFileObj.tree;
    if ismember('ipermut', timesFileVars)
        ipermut = timesFileObj.ipermut;
    end
else
    par = timesFileObj.par;
    par = updateParamForCluster(par, spikeFile);
    par.inputs = size(timesFileObj.inspk, 2);

    ipermut = getInspkAux(par, timesFileObj.inspk);
    [clu, tree] = run_cluster(par);
    spikeFileObj.clu = clu;
    spikeFileObj.tree = tree;
end

if size(clu, 2) - 2 < numSpikes
    clu = [clu, zeros(size(clu, 1), numSpikes - size(clu, 2) + 2)];
end

spikes = spikeFileObj.spikes;
if exist('ipermut', 'var') && ~isempty(ipermut)
    clu = permuteClu(clu, ipermut, numSpikes);
    USER_DATA{12} = ipermut;
end

if ismember("spikeIdxRejected", who(timesFileObj))
    % times_* file created by automatic clustering:
    spikes(timesFileObj.spikeIdxRejected, :) = [];
end

USER_DATA{2} = spikes;
USER_DATA{3} = spikeTimestamps(:)' * 1000;                      % convert from seconds to milliseconds.
USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = timesFileObj.inspk;
set(handles.wave_clus_figure, 'userdata', USER_DATA)            % I (Xin) really hate this way of passing data to wave_clus, we need to fix this.

end
