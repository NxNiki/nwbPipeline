function varargout = wave_clus(varargin)
% WAVE_CLUS M-file for wave_clus.fig
%      WAVE_CLUS, by itself, creates a new WAVE_CLUS or raises the existing
%      singleton*.
%
%      H = WAVE_CLUS returns the handle to a new WAVE_CLUS or the handle to
%      the existing singleton*.
%
%      WAVE_CLUS('Property','Value',...) creates a new WAVE_CLUS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wave_clus_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WAVE_CLUS('CALLBACK') and WAVE_CLUS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WAVE_CLUS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wave_clus
% Last Modified by GUIDE v2.5 10-Jan-2023 14:57:13

% JMG101208
% USER_DATA DEFINITIONS
% USER_DATA{1} = par;
% USER_DATA{2} = spikes;    % n * 74 spike waveform
% USER_DATA{3} = index;
% Xin: This is timestamps in milliseconds. See readData_ASCIISpikePreClustered.m
% Maybe it is updated?
% EM: This is not in time! This is in index, so if
%                           sampling rate is N, you must subtract 1 and
%                           divide by N to convert to time in seconds since
%                           recording start. Will save this value in USER_DATA{18}
% USER_DATA{4} = clu;
% USER_DATA{5} = tree;
% USER_DATA{7} = inspk;     % spike feature return by wave_features_wc.
% USER_DATA{6} = classes(:)'
% USER_DATA{8} = temp
% USER_DATA{9} = classes(:)', backup for non-forced classes
% USER_DATA{10} = clustering_results
% USER_DATA{11} = clustering_results_bk
% USER_DATA{12} = ipermut, indexes of the previously permuted spikes for clustering taking random number of points
% USER_DATA{13} - USER_DATA{17}, for future changes
% USER_DATA{18} = sampling frequency
% USER_DATA{19} = function to reject all spikes in a time range
% USER_DATA{20} - USER_DATA{42}, fix clusters

% add parent directory to search path so we don't need to do it manually:
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct( ...
    'gui_Name',  mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @wave_clus_OpeningFcn, ...
    'gui_OutputFcn',  @wave_clus_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before wave_clus is made visible.
function wave_clus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wave_clus
handles.output = hObject;
set(handles.data_type_popupmenu,'value',8);
handles.datatype = 'ASCII spikes (pre-clustered)';
set(handles.isi1_accept_button,'value',1);
set(handles.isi2_accept_button,'value',1);
set(handles.isi3_accept_button,'value',1);
set(handles.spike_shapes_button,'value',1);
set(handles.force_button,'value',0);
set(handles.plot_all_button,'value',1);
set(handles.plot_average_button,'value',0);
set(handles.fix1_button,'value',0);
set(handles.fix2_button,'value',0);
set(handles.fix3_button,'value',0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wave_clus wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = wave_clus_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

clus_colors = [0 0 1; 1 0 0; 0 0.5 0; 0 0.75 0.75; 0.75 0 0.75; 0.75 0.75 0; 0.25 0.25 0.25];
set(0,'DefaultAxesColorOrder', clus_colors)

% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
fprintf('Loading ')
set(handles.isi1_accept_button,'value',1);
set(handles.isi2_accept_button,'value',1);
set(handles.isi3_accept_button,'value',1);
set(handles.isi1_reject_button,'value',0);
set(handles.isi2_reject_button,'value',0);
set(handles.isi3_reject_button,'value',0);
set(handles.isi1_nbins,'string','Auto');
set(handles.isi1_bin_step,'string','Auto');
set(handles.isi2_nbins,'string','Auto');
set(handles.isi2_bin_step,'string','Auto');
set(handles.isi3_nbins,'string','Auto');
set(handles.isi3_bin_step,'string','Auto');
set(handles.isi0_nbins,'string','Auto');
set(handles.isi0_bin_step,'string','Auto');
set(handles.force_button,'value',0);
set(handles.force_button,'string','Force');
set(handles.fix1_button,'value',0);
set(handles.fix2_button,'value',0);
set(handles.fix3_button,'value',0);

thisTag = get(hObject,'Tag');
if isa(hObject,'matlab.ui.container.ContextMenu')
    thisTag = 'loadNext';
end

[pathname, fn, e] = fileparts(get(handles.file_name, 'String'));
fn = [fn, e];

timesFiles = dir(fullfile(pathname, 'times_G*.mat'));
timesFiles = {'', timesFiles(:).name, ''};
spikeFiles = cellfun(@timesFile2SpikeFile, timesFiles, "UniformOutput", false);

num = find(strcmp(spikeFiles, fn));
filename = '';
if ~isempty(num)
    switch thisTag
        case {'loadNext', 'rejectSaveLoad', 'saveAndLoadNext'}
            filename = spikeFiles{num+1};
        case {'loadPrevious', 'saveAndLoadPrevious'}
            filename = spikeFiles{num-1};
        case {'reloadThis'}
            filename = fn;
        case {'load_data_button'}
            if ~isempty(handles.channelToLoad.String)
                filename = strrep(fn, num, handles.channelToLoad.String);
                set(handles.channelToLoad, 'String', '');
            end
    end
end
fprintf('%s...', filename)

switch char(handles.datatype)
    case 'Simulator'
        cluster_class = readData_Simulator(filename, handles);
    case 'CSC data'                                              % Neuralynx (CSC files)
        cluster_class = readData_CSCData(filename, handles);
    case 'CSC data (pre-clustered)'                              % Neuralynx (CSC files)
        cluster_class = readData_CSCPreClustered(filename, handles);
    case 'Sc data'
        cluster_class = readData_ScData(filename, handles);
    case 'Sc data (pre-clustered)'
        cluster_class = readData_ScPreClustered(filename, handles);
    case 'ASCII'                                                 % ASCII matlab files
        cluster_class = readData_ASCII(filename, handles);
    case 'ASCII (pre-clustered)'                                 % ASCII matlab files
        cluster_class = readData_ASCIIpreClustered(filename, handles);
    case 'ASCII spikes'
        cluster_class = readData_ASCIISpikes(filename, handles);
    case 'ASCII spikes (pre-clustered)'
        if isempty(filename)
            [filename, pathname] = uigetfile('times_*.mat', 'Select file');
            if ~filename
                return
            end
            filename = timesFile2SpikeFile(filename);
        end
        [cluster_class, tree, ~, handles] = readData_ASCIISpikePreClustered(filename, pathname, handles);
end

temp=find_temp2(tree, handles);                                  % Selects temperature.
set(handles.file_name, 'string', fullfile(pathname, filename));

% EM: This is where identification gets set. But really, we want to use the
% classes from the times_CSC file because in the unsupervised case they
% already exist, and if we've looked at these spikes before, that is where
% they get saved.
guidata(hObject, handles);
USER_DATA = get(handles.wave_clus_figure, 'userdata');
spikes = USER_DATA{2};

% if size(clu,2)-2 < size(spikes, 1)
%     classes = clu(temp(end), 3:end)+1;
%     if ~exist('ipermut', 'var')
%         classes = [classes(:)' zeros(1, size(spikes, 1) - handles.par.max_spk)];
%     end
% else
%     classes = clu(temp(end), 3:end)+1;
% end

classes = cluster_class(:, 1);
saved_classes = cluster_class(:,1);
USER_DATA{6} = saved_classes(:)';
USER_DATA{8} = temp(end);
USER_DATA{9} = saved_classes(:)';                                     % backup for non-forced classes.

%% definition of clustering_results
classes = rejectPositiveSpikes(spikes, classes(:), handles.par);
clustering_results      = [];
clustering_results(:,1) = repmat(temp, length(classes),1); % GUI temperatures
clustering_results(:,2) = classes; % GUI classes
clustering_results(:,3) = repmat(temp, length(classes),1); % original temperatures
clustering_results(:,4) = classes'; % original classes
clustering_results(:,5) = repmat(handles.par.min_clus, length(classes),1); % minimum number of clusters
clustering_results_bk   = clustering_results; % old clusters for undo actions
USER_DATA{10} = clustering_results;
USER_DATA{11} = clustering_results_bk;

handles = updateHandles(hObject, handles, [], {'setclus', 'force', 'merge', 'undo', 'reject'}, [], handles.par.min_clus);
set(handles.wave_clus_figure, 'userdata', USER_DATA);

%% Add sampling rate info
if length(USER_DATA)<18 || isempty(USER_DATA{18})
    samplingRate = questdlg('What was the sampling rate?', 'SR', '30000', '32000', '40000', '32000');
    samplingRate = eval(samplingRate);
else
    samplingRate = USER_DATA{18};
end

cla(handles.cont_data)
USER_DATA{18} = samplingRate;
set(handles.wave_clus_figure, 'userdata', USER_DATA)

%% mark clusters when new data is loaded
plot_spikes(handles);
mark_clusters_temperature_diagram(handles, tree, clustering_results, 1);
fprintf('Finished!\n')

% --- Executes on button press in change_temperature_button.
function change_temperature_button_Callback(hObject, eventdata, handles)
axes(handles.temperature_plot)
hold off
[temp, aux]= ginput(1);                                          %gets the mouse input
temp = round((temp-handles.par.mintemp)/handles.par.tempstep);
if temp < 1; temp=1; end                                         %temp should be within the limits
if temp > handles.par.num_temp; temp=handles.par.num_temp; end
min_clus = round(aux);
set(handles.min_clus_edit, 'string', num2str(min_clus));

USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};
spikes = USER_DATA{2};
par.min_clus = min_clus;
clu = USER_DATA{4};
classes = clu(temp, 3:end) + 1;
tree = USER_DATA{5};

classes = rejectPositiveSpikes(spikes, classes); % why par.w_pre is a vector here?

USER_DATA{1} = par;
USER_DATA{6} = classes(:)';
USER_DATA{8} = temp;
USER_DATA{9} = classes(:)';                                     %backup for non-forced classes.
handles.par.num_temp = min(handles.par.num_temp, size(clu, 1));

clustering_results = USER_DATA{10};
clustering_results(:, 2) = classes;
USER_DATA{10} = clustering_results;

handles.minclus = min_clus;
set(handles.wave_clus_figure, 'userdata', USER_DATA);

% temperature = handles.par.mintemp + temp * handles.par.tempstep;
% switch par.temp_plot
%     case 'lin'
%         plot([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep],[par.min_clus par.min_clus],'k:',...
%             handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
%             tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
%     case 'log'
%         handles.par.num_temp = min(size(tree,1),handles.par.num_temp);
%         semilogy([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
%             [par.min_clus par.min_clus],'k:',...
%             handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
%             tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
% end
% xlim([0 handles.par.maxtemp])
% xlabel('Temperature');
% if strcmp(par.temp_plot, 'log')
%     set(get(gca,'ylabel'), 'vertical', 'Cap');
% else
%     set(get(gca,'ylabel'), 'vertical', 'Baseline');
% end
% ylabel('Clusters size');

handles = updateHandles(hObject, handles, [], {'setclus', 'force', 'merge', 'undo', 'reject'});
plot_spikes(handles);

USER_DATA = get(handles.wave_clus_figure, 'userdata');
clustering_results = USER_DATA{10};
mark_clusters_temperature_diagram(handles, tree, clustering_results, 1)

set(handles.fix1_button, 'value', 1);
updateFixButtonHandle(hObject, handles)

% --- Change min_clus_edit
function min_clus_edit_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};
clu = USER_DATA{4};
tree = USER_DATA{5};
temp = USER_DATA{8};

classes = clu(temp,3:end)+1;
par.min_clus = str2double(get(hObject, 'String'));

USER_DATA{1} = par;
USER_DATA{6} = classes(:)';
USER_DATA{9} = classes(:)';                                     % backup for non-forced classes.
clustering_results = USER_DATA{10};
clustering_results(:,5) = par.min_clus;
set(handles.wave_clus_figure, 'userdata', USER_DATA);

mark_clusters_temperature_diagram(handles, tree, clustering_results)
handles = updateHandles(hObject, handles, [], {'setclus', 'force', 'merge', 'undo', 'reject'}, [], par.min_clus);

plot_spikes(handles);
mark_clusters_temperature_diagram(handles, tree, clustering_results)

set(handles.force_button, 'value', 0);
set(handles.force_button, 'string', 'Force');
updateFixButtonHandle(hObject, handles)

% --- Executes on button press in save_clusters_button.
function save_clusters_button_Callback(hObject, eventdata, handles)
fprintf('Saving...')
reorderSpikeRasters('reset')
USER_DATA = get(handles.wave_clus_figure, 'userdata');
spikes = USER_DATA{2};
par = USER_DATA{1};
classes = shrinkClassIndex(USER_DATA{6});
temp = USER_DATA{8};

% get user name:
sortedBy = handles.sorterName.String;
if isempty(sortedBy) || strcmp(sortedBy, 'Enter your name')
    n = inputdlg('Please enter your name', 'Sorter''s name?', 1);
    sortedBy = n{1};
    handles.sorterName.String = sortedBy;
end

% Saves clusters
cluster_class = zeros(size(spikes, 1), 2);
cluster_class(:,1) = classes(:);
cluster_class(:,2) = USER_DATA{3}' / 1000;

[pathname, fn] = fileparts(get(handles.file_name, 'String'));
outFileName = strrep(['times_manual_' fn], '_spikes', '');
outfile = fullfile(pathname, outFileName);

outFileObj = matfile(outfile, "Writable", true);

if ~ismember('sortedBy', who(outFileObj)) || ~iscell(outFileObj.sortedBy)
    sortedByPrev = [];
else
    sortedByPrev = outFileObj.sortedBy;
end

sortedByPrev = [sortedByPrev; {sortedBy, char(datetime("now"))}];

outFileObj.sortedBy = sortedByPrev;
outFileObj.cluster_class = cluster_class;
outFileObj.temp = temp;
% outFileObj.par = par;
% outFileObj.spikes = spikes;
% outFileObj.ipermut = USER_DATA{12};
% outFileObj.inspk = USER_DATA{7};

%Save figures
nClusts = max(cluster_class(:,1));
switch outFileName(7:9)
    case 'pol'
        startInd = 10;
    otherwise
        startInd = 7;
end

h_figs = get(0, 'children');
saveWaveClusFigure(h_figs, 'wave_clus_figure',   pathname, outFileName(startInd:end))
if nClusts>3
    saveWaveClusFigure(h_figs, 'wave_clus_aux',  pathname, outFileName(startInd:end))
end
if nClusts>8
    saveWaveClusFigure(h_figs, 'wave_clus_aux1', pathname, outFileName(startInd:end))
end
if nClusts>13
    saveWaveClusFigure(h_figs, 'wave_clus_aux2', pathname, outFileName(startInd:end))
end
if nClusts>18
    saveWaveClusFigure(h_figs, 'wave_clus_aux3', pathname, outFileName(startInd:end))
end
if nClusts>23
    saveWaveClusFigure(h_figs, 'wave_clus_aux4', pathname, outFileName(startInd:end))
end
if nClusts>28
    saveWaveClusFigure(h_figs, 'wave_clus_aux5', pathname, outFileName(startInd:end))
end
fprintf('Finished!\n')

% --- Executes on selection change in data_type_popupmenu.
function data_type_popupmenu_Callback(hObject, eventdata, handles)
aux = get(hObject, 'String');
aux1 = get(hObject, 'Value');
handles.datatype = aux(aux1);
guidata(hObject, handles);

% --- Executes on button press in set_parameters_button.
function set_parameters_button_Callback(hObject, eventdata, handles)
helpdlg('Check the set_parameters files in the subdirectory Wave_clus\Parameters_files');

% SETTING OF FORCE MEMBERSHIP
% --------------------------------------------------------------------
function force_button_Callback(hObject, eventdata, handles)
%set(gcbo,'value',1);
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
spikes = USER_DATA{2};
classes = USER_DATA{6};
inspk = USER_DATA{7};

% Fixed clusters are not considered for forcing
if get(handles.fix1_button,'value') ==1
    fix_class = USER_DATA{20}';
    classes(fix_class)=-1;
end
if get(handles.fix2_button,'value') ==1
    fix_class = USER_DATA{21}';
    classes(fix_class)=-1;
end
if get(handles.fix3_button,'value') ==1
    fix_class = USER_DATA{22}';
    classes(fix_class)=-1;
end
% Get fixed clusters from aux figures
for i=4:par.max_clus
    if par.(['fix', num2str(i)]) == 1
        fix_class = USER_DATA{22+i-3}';
        classes(fix_class)=-1;
    end
end

switch par.force_feature
    case 'spk'
        f_in  = spikes(classes~=0 & classes~=-1,:);
        f_out = spikes(classes==0,:);
    case 'wav'
        if isempty(inspk)
            [inspk] = wave_features_wc(spikes, handles);        % Extract spike features.
            USER_DATA{7} = inspk;
        end
        f_in  = inspk(classes~=0 & classes~=-1,:);
        f_out = inspk(classes==0,:);
end

class_in = classes(classes~=0 & classes~=-1);
class_out = force_membership_wc(f_in, class_in, f_out, par);
classes(classes==0) = class_out;

USER_DATA{6} = classes(:)';
set(handles.wave_clus_figure, 'userdata', USER_DATA)

handles = updateHandles(hObject, handles, {'setclus', 'force'}, {'merge', 'reject', 'undo'}, 10);
plot_spikes(handles);
updateFixButtonHandle(hObject, handles);

% PLOT ALL PROJECTIONS BUTTON
% --------------------------------------------------------------------
function Plot_all_projections_button_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};

if strcmp(par.filename(1:4),'poly')
    % do we need this part? Xin.
    Plot_amplitudes(handles)
else
    Plot_all_features(handles)
end

% fix1 button --------------------------------------------------------------------
function fix1_button_Callback(hObject, eventdata, handles)
fixButton(hObject, handles, 1, 20, 'fix1_button')

% fix2 button --------------------------------------------------------------------
function fix2_button_Callback(hObject, eventdata, handles)
fixButton(hObject, handles, 2, 21, 'fix2_button')

% fix3 button --------------------------------------------------------------------
function fix3_button_Callback(hObject, eventdata, handles)
fixButton(hObject, handles, 3, 22, 'fix3_button')

%SETTING OF SPIKE FEATURES OR PROJECTIONS
% --------------------------------------------------------------------
function spike_shapes_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.spike_features_button,'value',0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles);

% -------------------------------------------------------------------
function spike_features_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.spike_shapes_button,'value',0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles);

%SETTING OF SPIKE PLOTS
% --------------------------------------------------------------------
function plot_all_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_average_button, 'value', 0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles);

% --------------------------------------------------------------------
function plot_average_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_all_button, 'value', 0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles);

%% SETTING OF ISI HISTOGRAMS
% --------------------------------------------------------------------
function isi1_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins1');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi1_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step1');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi2_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins2');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi2_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step2');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi3_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins3');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi3_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step3');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi0_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins0');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

% --------------------------------------------------------------------
function isi0_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step0');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'}, 10);
plot_spikes(handles)

%SETTING OF ISI BUTTONS
% --------------------------------------------------------------------
function isi1_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi1_reject_button,'value',0);

% --------------------------------------------------------------------
function isi1_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);
[handles, USER_DATA, tree] = rejectCluster(hObject, handles, 1);
handles = updateHandles(hObject, handles, {'setclus', 'reject'}, {'force', 'merge',  'undo'}, 10);
plot_spikes(handles)

clustering_results = USER_DATA{10};
mark_clusters_temperature_diagram(handles, tree, clustering_results)
set(handles.wave_clus_figure, 'userdata', USER_DATA);

set(hObject, 'value', 0);
set(handles.isi1_accept_button, 'value', 1);

% --------------------------------------------------------------------
function isi2_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi2_reject_button, 'value', 0);

% --------------------------------------------------------------------
function isi2_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);
[handles, USER_DATA, tree] = rejectCluster(hObject, handles, 2);
handles = updateHandles(hObject, handles, {'setclus','reject'}, {'force', 'merge',  'undo'}, 10);
plot_spikes(handles)

clustering_results = USER_DATA{10};
mark_clusters_temperature_diagram(handles, tree, clustering_results)
set(handles.wave_clus_figure, 'userdata', USER_DATA);

set(hObject, 'value', 0);
set(handles.isi2_accept_button, 'value', 1);

% --------------------------------------------------------------------
function isi3_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi3_reject_button, 'value', 0);

% --------------------------------------------------------------------
function isi3_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);
[handles, USER_DATA, tree] = rejectCluster(hObject, handles, 3);
handles = updateHandles(hObject, handles, {'setclus','reject'}, {'force', 'merge',  'undo'}, 10);
plot_spikes(handles)

clustering_results = USER_DATA{10};
mark_clusters_temperature_diagram(handles, tree, clustering_results)
set(handles.wave_clus_figure, 'userdata', USER_DATA);

set(hObject, 'value', 0);
set(handles.isi3_accept_button, 'value', 1);

% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)

handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'}, 11);
USER_DATA = get(handles.wave_clus_figure, 'userdata');
clustering_results_bk = USER_DATA{11};
USER_DATA{6} = clustering_results_bk(:,2); % old gui classes
USER_DATA{10} = clustering_results_bk;
USER_DATA{8} = clustering_results_bk(1,1); % old gui temperatures
set(handles.wave_clus_figure, 'userdata', USER_DATA)
plot_spikes(handles) % plot_spikes updates USER_DATA{11}

tree = USER_DATA{5};
mark_clusters_temperature_diagram(handles, tree, clustering_results_bk)
set(handles.min_clus_edit, 'string', num2str(handles.minclus));
updateFixButtonHandle(hObject, handles)

% --- Executes on button press in merge_button.
function merge_button_Callback(hObject, eventdata, handles)

handles = updateHandles(hObject, handles, {'merge'}, {'setclus', 'reject', 'force', 'undo'}, 10);
plot_spikes(handles)

USER_DATA = get(handles.wave_clus_figure, 'userdata');
tree = USER_DATA{5};
clustering_results = USER_DATA{10};
mark_clusters_temperature_diagram(handles, tree, clustering_results)
updateFixButtonHandle(hObject, handles)

% --- Executes on button press in Plot_polytrode_channels_button.
function Plot_polytrode_button_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};
if strcmp(par.filename(1:9), 'polytrode')
    Plot_polytrode(handles)
elseif strcmp(par.filename(1:13), 'C_sim_script_')
    handles.simname = par.filename;
    Plot_simulations(handles)
end

% --- Executes during object creation, after setting all properties.
function isi1_nbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi1_nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi1_bin_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi1_bin_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi2_nbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi2_nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi2_bin_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi2_bin_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi3_nbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi3_nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi3_bin_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi3_bin_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi0_nbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi0_nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function isi0_bin_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi0_bin_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function min_clus_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_clus_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function data_type_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_type_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in reloadThis.
function reloadThis_Callback(hObject, eventdata, handles)
% hObject    handle to reloadThis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in rejectSaveLoad.
function rejectSaveLoad_Callback(hObject, eventdata, handles)
% hObject    handle to rejectSaveLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

USER_DATA = get(handles.wave_clus_figure, 'userdata');
classes = USER_DATA{6};
classes = zeros(size(classes));
USER_DATA{6} = classes(:)';
set(handles.wave_clus_figure, 'userdata', USER_DATA)

handles = updateHandles(hObject, handles, [], {'setclus', 'reject', 'force', 'undo', 'merge'}, 10);
plot_spikes(handles);

save_clusters_button_Callback(hObject, eventdata, handles)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in excludeTimesButton.
function excludeTimesButton_Callback(hObject, eventdata, handles)
% hObject    handle to excludeTimesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'}, 11);
USER_DATA = get(handles.wave_clus_figure, 'userdata');
curr_func = USER_DATA{19};
if isempty(curr_func)
    curr_func = '';
end
new_func = inputdlg(['Please enter an anonymous function of one variable, ',...
    'f(t), such that if f(spikeTime) is TRUE, that spike will be rejeted. ',...
    'For example, to reject all spikes between 500 and 520 seconds, enter ',...
    '@(t)t > 500 & t < 520. To include all spikes, regardless of spike time,',...
    ' leave this blank then FORCE or change temperature to get spikes back ',...
    'into classes. Note: It is HIGHLY RECOMMENDED that you only use this ',...
    'function for excluding spikes during times when you know you will not',...
    ' analyze data (e.g. between trials when noise was introduced)'],...
    'Enter exclusion function', 1, {curr_func});

if isempty(new_func)
    return
end
USER_DATA{19} = new_func{1};
classes = USER_DATA{6};
ts = USER_DATA{3}*1e-3;
if ~isempty(new_func{1})
    f = eval(new_func{1});
    rejectInds = f(ts);
    classes(rejectInds) = 0;
end
USER_DATA{6} = classes;
set(handles.wave_clus_figure, 'userdata', USER_DATA);
plot_spikes(handles)

% --- Executes on button press in mahalDistRemoveSpikes.
function mahalDistRemoveSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to mahalDistRemoveSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('Removing spikes by Mahalanobis Distance...')
handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'}, 11);

USER_DATA = get(handles.wave_clus_figure, 'userdata');
classes = USER_DATA{6};
inspk = USER_DATA{7};
warning('off','MATLAB:nearlySingularMatrix');
for i=1:max(classes)
    inCluster = classes == i;
    nSpikes = sum(inCluster);
    newNSpikes = 0;
    nFeatures = size(inspk, 2);
    while nSpikes > nFeatures && nSpikes>newNSpikes
        inCluster = classes == i;
        nSpikes = sum(inCluster);
        M = mahal(inspk,inspk(inCluster, :));
        Lspk = 1-chi2cdf(M, nFeatures);
        removeFromClust = inCluster(:) & Lspk(:) < 5e-4;
        classes(removeFromClust) = 0;
        newNSpikes = sum(classes == i);
    end
end
warning('on','MATLAB:nearlySingularMatrix');
USER_DATA{6} = classes;
set(handles.wave_clus_figure,'userdata', USER_DATA);
plot_spikes(handles)
fprintf('Finished!\n')

% --- Executes on button press in PlotContinuous.
function PlotContinuous_Callback(hObject, eventdata, handles)
% hObject    handle to PlotContinuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add continuous data to plot
cscData = load(fullfile(handles.par.pathname, handles.par.filename));
cscData.data = reshape(cscData.data, 1, []);
samplingRate = 1000/cscData.samplingInterval;
cscData.data = resample(double(cscData.data), 1000, samplingRate);
ts = 0:(1/1000):(length(cscData.data)-1)/1000;
plot(handles.cont_data, ts, cscData.data)
M = prctile(abs(cscData.data), 99.75);
set(handles.cont_data, 'xlim', [0,ts(end)], 'ylim', [-M M])
set(handles.spikeRaster, 'xlim', [0,ts(end)])
spikesName = regexprep(handles.par.filename, '(\d+)', '$1_spikes');
try
    hold(handles.cont_data, 'on')
    load(spikesName, 'timesZeroedOutForSpikeDetection');
    for i=1:size(timesZeroedOutForSpikeDetection, 1)
        plot(handles.cont_data, timesZeroedOutForSpikeDetection(i,:), [0 0], 'y', 'linewidth', 3);
    end
end
% --- Executes on button press in noiseReject.
function noiseReject_Callback(hObject, eventdata, handles)
% hObject    handle to noiseReject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function channelToLoad_Callback(hObject, eventdata, handles)
% hObject    handle to channelToLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelToLoad as text
%        str2double(get(hObject,'String')) returns contents of channelToLoad as a double

% --- Executes during object creation, after setting all properties.
function channelToLoad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in loadPrevious.
function loadPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to loadPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in loadNext.
function loadNext_Callback(hObject, eventdata, handles)
% hObject    handle to loadNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in saveAndLoadPrevious.
function saveAndLoadPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndLoadPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_clusters_button_Callback(hObject, eventdata, handles)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in saveAndLoadNext.
function saveAndLoadNext_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndLoadNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_clusters_button_Callback(hObject, eventdata, handles)
load_data_button_Callback(hObject, eventdata, handles)

function sorterName_Callback(hObject, eventdata, handles)
% hObject    handle to sorterName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sorterName as text
%        str2double(get(hObject,'String')) returns contents of sorterName as a double

% --- Executes during object creation, after setting all properties.
function sorterName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sorterName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
