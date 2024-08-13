function [cluster_class, tree, clu, handles] = readData_ASCIISpikePreClustered(filename, pathname, handles)
% This function read *_spikes.mat file with corresponding times_*.mat,
% data_*.dg_01 and data_*.dg_01.lab file.

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

filename = strrep(filename, '_spikes','');
timesFile = fullfile(pathname, ['times_', filename]);
if ~exist(timesFile, 'file')
    warning([timesFile, ' does not exist. Move on...'])
    return
end

timesFileObj = matfile(timesFile);
cluster_class = timesFileObj.cluster_class;
manualTimesFile = fullfile(pathname, ['times_manual_' filename]);
if exist(manualTimesFile, 'file')
    message = 'This spike file has been manually sorted, do you want to load the previous result?';
    title = 'Spikes manually sorted already!';
    option1 = 'Yes';
    option2 = 'No';
    
    % Create the dialog box
    choice = questdlg(message, title, option1, option2, option1);
    if strcmp(choice, option1)
        manualTimesFileObj = matfile(manualTimesFile);
        cluster_class = manualTimesFileObj.cluster_class;
    end
end

spikeTimestamps=cluster_class(:, 2)'; % timestamps of spikes; gets loaded in line above.

spikeFileVars = who(spikeFileObj);
if ismember('clu', spikeFileVars) && ismember('tree', spikeFileVars)
    clu = spikeFileObj.clu;
    tree = spikeFileObj.tree;
else
    par = timesFileObj.par;
    par = updateParamForCluster(par, spikeFile);
    par.inputs = size(timesFileObj.inspk, 2);

    getInspkAux(par, timesFileObj.inspk)
    [clu, tree] = run_cluster(par);
    spikeFileObj.clu = clu;
    spikeFileObj.tree = tree;
end

USER_DATA = get(handles.wave_clus_figure, 'userdata');
if ismember('ipermut', who(timesFileObj))
    clu = permuteClu(clu, timesFileObj.ipermut);
    USER_DATA{12} = timesFileObj.ipermut;
end

% This might never run (and may be wrong, should not + 1000).
% if exist('ipermut', 'var')
%     clu_aux = zeros(size(clu,1), length(spikeTimestamps)) + 1000;
%     for i=1:length(ipermut)
%         clu_aux(:,ipermut(i)+2) = clu(:,i+2);
%     end
%     clu_aux(:,1:2) = clu(:,1:2);
%     clu = clu_aux; clear clu_aux
%     USER_DATA{12} = ipermut;
% end

spikes = spikeFileObj.spikes;
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