function readData_ASCIIPreClustered(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.mat','Select file'); if ~filename,return;end
end
set(handles.file_name,'string',['Loading:    ' pathname filename]);

% handles.par = set_parameters_ascii_spikes(filename,handles);     %Load parameters
handles.par = set_joint_parameters_CSC(filename); %EM: Replaced the default wave_clus parameters with those that we've been using
% HISTOGRAM PARAMETERS
for i=1:handles.par.max_clus+1
    eval(['par.nbins' num2str(i-1) ' = 100;']);  % # of bins for the ISI histograms
    eval(['par.bin_step' num2str(i-1) ' = 1;']);  % percentage number of bins to plot
end

% Sets to zero fix buttons from aux figures
for i=4:handles.par.max_clus
    eval(['par.fix' num2str(i) '=0;'])
end
try % will fail on initial call, but not when data is being loaded?
    par.filename = filename;
end
USER_DATA = get(handles.wave_clus_figure,'userdata');
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));
% axes(handles.cont_data); EM: removed call to axes.
cla(handles.cont_data);

%Load spikes and parameters
spikeFileObj = matfile(fullfile(pathname, filename));

% we want to make it possible to choose the _spikes file but still
% load the times_ file. So we just remove _spikes from the filename
% first.
filename = strrep(filename,'_spikes','');
timesFile = fullfile(pathname, ['times_',filename]);
if ~exist(timesFile,'file')
    warning([timesFile, ' does not exist. Move on...'])
    return
end
load(timesFile);
index=cluster_class(:,2)'; %timestamps of spikes; gets loaded in line above.

%Load clustering results
fname = [handles.par.fname '_' filename(1:end-4)];               %filename for interaction with SPC
if ~exist([fname '.dg_01.lab'],'file')
    fname = strrep(fname,'CSC','ch');
end
clu  = load(fullfile(pathname, [fname '.dg_01.lab']));
tree = load(fullfile(pathname, [fname '.dg_01']));
handles.par.fnamespc  = fname;
handles.par.fnamesave = fname;

USER_DATA = get(handles.wave_clus_figure, 'userdata');

if exist('ipermut')
    clu_aux = zeros(size(clu,1),length(index)) + 1000;
    for i=1:length(ipermut)
        clu_aux(:,ipermut(i)+2) = clu(:,i+2);
    end
    clu_aux(:,1:2) = clu(:,1:2);
    clu = clu_aux; clear clu_aux
    USER_DATA{12} = ipermut;
end

spikes = spikeFileObj.spikes;
spikes(spikeIdxRejected) = [];
USER_DATA{2} = spikes;
USER_DATA{3} = index(:)';
USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = inspk;
set(handles.wave_clus_figure, 'userdata', USER_DATA)
end