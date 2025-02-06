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
% Last Modified by GUIDE v2.5 24-Jan-2025 18:31:08

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
set(handles.spike_shapes_button,'value',1);
set(handles.force_button,'value',0);
set(handles.plot_all_button,'value',1);
set(handles.plot_average_button,'value',0);

handles.clusterIdx = 1:3;
plotLabelIdx = 1:3;
handles.plotLabelIdx = plotLabelIdx;
radiobuttonIdx = [22, 25, 28];
for i = 1:3
    set(handles.(sprintf('isi%d_accept_button', plotLabelIdx(i))), 'value', 1);
    set(handles.(sprintf('fix%d_button', plotLabelIdx(i))), 'value', 0);
    set(handles.(sprintf('radiobutton%d', radiobuttonIdx(i))), 'value', 1);
end

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

clus_colors = [
    0 0 1; 
    1 0 0; 
    0 0.5 0; 
    0 0.75 0.75; 
    0.75 0 0.75; 
    0.75 0.75 0; 
    0.25 0.25 0.25
    ];
set(0,'DefaultAxesColorOrder', clus_colors)

% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
fprintf('Loading ');

set(handles.isi0_nbins,'string','Auto');
set(handles.isi0_bin_step,'string','Auto');
set(handles.force_button,'value',0);
set(handles.force_button,'string','Force');

for i = 1:3
    set(handles.(sprintf('isi%d_accept_button', i)),'value',1);
    set(handles.(sprintf('isi%d_reject_button', i)),'value',0);
    set(handles.(sprintf('isi%d_nbins', i)),'string','Auto');
    set(handles.(sprintf('isi%d_bin_step', i)),'string','Auto');
    set(handles.(sprintf('fix%d_button', i)),'value',0);
end

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
            [filename, pathname] = uigetfile([pathname, filesep, 'times_*.mat'], 'Select file');
            if ~filename
                return
            end
            filename = timesFile2SpikeFile(filename);
        end
        [cluster_class, handles] = readData_ASCIISpikePreClustered(filename, pathname, handles);
end

set(handles.file_name, 'String', fullfile(pathname, filename));
if size(cluster_class, 2) == 3
    cluster_class_unit_type = unique(cluster_class(:, [1, 3]), 'rows');
    radiobuttonLabels = {'22','23','24'; '25', '26', '27'; '28', '29', '30'};
    for i = 1:size(cluster_class_unit_type, 1)
        clusterIdx = cluster_class_unit_type(i, 1);
        unitTypeIdx = cluster_class_unit_type(i, 2);
        if clusterIdx > 0
            handles.clusterUnitType(clusterIdx) = unitTypeIdx;
            if clusterIdx <= 3
                radiobuttonLabel = radiobuttonLabels{clusterIdx, unitTypeIdx};
                rb = handles.(sprintf('radiobutton%s', radiobuttonLabel));
                set(handles.(sprintf('uibuttongroup%d', clusterIdx)), 'SelectedObject', rb);
            end
        end
    end
end

% EM: This is where identification gets set. But really, we want to use the
% classes from the times_CSC file because in the unsupervised case they
% already exist, and if we've looked at these spikes before, that is where
% they get saved.
% guidata(hObject, handles);
handles = updateHandles(hObject, handles, [], {'setclus', 'force', 'merge', 'undo', 'reject'});
cla(handles.cont_data)

guidata(hObject, handles);
plot_spikes(handles);
mark_clusters_temperature_diagram(handles, 1);
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

% set(handles.min_clus_edit, 'string', num2str(min_clus));

[spikes, clu, clustering_results] = getUserData([2, 4, 10]);

handles.min_clus = min_clus;
handles.par.num_temp = min(handles.par.num_temp, size(clu, 1));

classes = clu(temp, 3:end) + 1;
classes = rejectPositiveSpikes(spikes, classes); % why par.w_pre is a vector here?
clustering_results(:, 2) = classes;

setUserData({classes(:)', temp, classes(:)', clustering_results}, [6, 8, 9, 10]);

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

clustering_results = getUserData(10);
mark_clusters_temperature_diagram(handles, 1)

% update unit type as n clusters change:
nClusters = length(unique(clustering_results(:, 2))) - 1;
handles.clusterUnitType = int8(ones(1, nClusters));

% set(handles.fix1_button, 'value', 1);
% updateFixButtonHandle(hObject, handles)
unFixAllClusters();

% --- Change min_clus_edit
function min_clus_edit_Callback(hObject, eventdata, handles)

[clu, temp, clustering_results] = getUserData([4, 8, 10]);
classes = clu(temp, 3:end) + 1;
handles.min_clus = str2double(get(hObject, 'String'));
clustering_results(:,5) = handles.min_clus;
setUserData({classes(:)', classes(:)', clustering_results}, [6, 9, 10]);

mark_clusters_temperature_diagram(handles)
handles = updateHandles(hObject, handles, [], {'setclus', 'force', 'merge', 'undo', 'reject'});

plot_spikes(handles);
mark_clusters_temperature_diagram(handles)

set(handles.force_button, 'value', 0);
set(handles.force_button, 'string', 'Force');
% updateFixButtonHandle(hObject, handles)
unFixAllClusters();

% --- Executes on button press in save_clusters_button.
function save_clusters_button_Callback(hObject, eventdata, handles)
fprintf('Saving...\n');
reorderSpikeRasters('reset')

[spikes, spikeTimestamps, classes, temp] = getUserData([2, 3, 6, 8]);

% get user name:
sortedBy = handles.sorterName.String;
if isempty(sortedBy) || strcmp(sortedBy, 'Enter your name')
    n = inputdlg('Please enter your name', 'Sorter''s name?', 1);
    sortedBy = n{1};
    handles.sorterName.String = sortedBy;
end

% Saves clusters
cluster_class = zeros(size(spikes, 1), 3);
cluster_class(:,1) = classes(:);
cluster_class(:,2) = spikeTimestamps(:) / 1000;
cluster_class(:,3) = 1;

for i = 1:length(handles.clusterUnitType)
    cluster_class(classes(:)==i, 3) = handles.clusterUnitType(i);
end

[pathname, outFileName] = fileparts(handles.manualTimesFile);
outFileObj = matfile(handles.manualTimesFile, "Writable", true);

if ~ismember('sortedBy', who(outFileObj)) || ~iscell(outFileObj.sortedBy)
    sortedByPrev = [];
else
    sortedByPrev = outFileObj.sortedBy;
end
sortedByPrev = [sortedByPrev; {sortedBy, char(datetime("now"))}];

outFileObj.sortedBy = sortedByPrev;
outFileObj.cluster_class = cluster_class;
outFileObj.temp = temp;
outFileObj.min_clus = handles.min_clus;

%Save figures
nClusts = max(cluster_class(:,1));
switch outFileName(7:9)
    case 'pol'
        startInd = 10;
    otherwise
        startInd = 7;
end

h_figs = get(0, 'children');
saveWaveClusFigure(h_figs, 'wave_clus_figure', pathname, outFileName(startInd:end))
if nClusts>3
    saveWaveClusFigure(h_figs, 'wave_clus_aux', pathname, outFileName(startInd:end))
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

fprintf('Cluster saved to: %s!\n', handles.manualTimesFile);

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

[par, spikes, classes, inspk] = getUserData([1, 2, 6, 7]);

% Fixed clusters are not considered for forcing
if get(handles.fix1_button,'value') ==1
    classes(classes==1)=-1;
end
if get(handles.fix2_button,'value') ==1
    classes(classes==2)=-1;
end
if get(handles.fix3_button,'value') ==1
    classes(classes==3)=-1;
end
% Get fixed clusters from aux figures
for i=4:par.max_clus
    if handles.clusterFixed(i) == 1
        classes(classes==i)=-1;
    end
end

switch par.force_feature
    case 'spk'
        f_in  = spikes(classes~=0 & classes~=-1,:);
        f_out = spikes(classes==0,:);
    case 'wav'
        if isempty(inspk)
            [inspk] = wave_features_wc(spikes, handles);        % Extract spike features.
        end
        f_in  = inspk(classes~=0 & classes~=-1,:);
        f_out = inspk(classes==0,:);
end

class_in = classes(classes~=0 & classes~=-1);
class_out = force_membership_wc(f_in, class_in, f_out, par);
classes(classes==0) = class_out;

setUserData({classes(:)', inspk}, [6, 7]);

handles = updateHandles(hObject, handles, {'setclus', 'force'}, {'merge', 'reject', 'undo'});
plot_spikes(handles);
% updateFixButtonHandle(hObject, handles);
unFixAllClusters();

% PLOT ALL PROJECTIONS BUTTON
% --------------------------------------------------------------------
function Plot_all_projections_button_Callback(hObject, eventdata, handles)

[~, filename] = fileparts(get(handles.file_name, 'String'));

if strcmp(filename(1:4), 'poly')
    % do we need this part? Xin.
    Plot_amplitudes(handles)
else
    Plot_all_features(handles)
end

% fix1 button --------------------------------------------------------------------
function fix1_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 1);

% fix2 button --------------------------------------------------------------------
function fix2_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 2);

% fix3 button --------------------------------------------------------------------
function fix3_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 3);

%SETTING OF SPIKE FEATURES OR PROJECTIONS
% --------------------------------------------------------------------
function spike_shapes_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.spike_features_button,'value',0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles);

% -------------------------------------------------------------------
function spike_features_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.spike_shapes_button,'value',0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles);

%SETTING OF SPIKE PLOTS
% --------------------------------------------------------------------
function plot_all_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_average_button, 'value', 0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles);

% --------------------------------------------------------------------
function plot_average_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_all_button, 'value', 0);
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles);

%% SETTING OF ISI HISTOGRAMS
% --------------------------------------------------------------------
function isi1_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins1');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi1_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step1');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi2_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins2');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi2_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step2');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi3_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins3');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi3_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step3');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi0_nbins_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'nbins0');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

% --------------------------------------------------------------------
function isi0_bin_step_Callback(hObject, eventdata, handles)
handles = updateParam(hObject, handles, 'bin_step0');
handles = updateHandles(hObject, handles, {'setclus'}, {'force', 'merge', 'reject', 'undo'});
plot_spikes(handles)

%SETTING OF ISI BUTTONS
% --------------------------------------------------------------------
function isi1_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi1_reject_button,'value',0);

% --------------------------------------------------------------------
function isi1_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);

[handles, clustering_results, tree] = rejectCluster(hObject, handles, 1);
handles = updateHandles(hObject, handles, {'setclus', 'reject'}, {'force', 'merge',  'undo'});
plot_spikes(handles)
mark_clusters_temperature_diagram(handles)

set(hObject, 'value', 0);
set(handles.isi1_accept_button, 'value', 1);

% --------------------------------------------------------------------
function isi2_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi2_reject_button, 'value', 0);

% --------------------------------------------------------------------
function isi2_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);

[handles, clustering_results, tree] = rejectCluster(hObject, handles, 2);
handles = updateHandles(hObject, handles, {'setclus', 'reject'}, {'force', 'merge',  'undo'});
plot_spikes(handles)
mark_clusters_temperature_diagram(handles)

set(hObject, 'value', 0);
set(handles.isi2_accept_button, 'value', 1);

% --------------------------------------------------------------------
function isi3_accept_button_Callback(hObject, eventdata, handles)
set(hObject,'value',1);
set(handles.isi3_reject_button, 'value', 0);

% --------------------------------------------------------------------
function isi3_reject_button_Callback(hObject, eventdata, handles)
set(hObject, 'value', 1);

[handles, clustering_results, tree] = rejectCluster(hObject, handles, 3);
handles = updateHandles(hObject, handles, {'setclus', 'reject'}, {'force', 'merge',  'undo'});
plot_spikes(handles)
mark_clusters_temperature_diagram(handles)

set(hObject, 'value', 0);
set(handles.isi3_accept_button, 'value', 1);

% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)

clustering_results_bk = getUserData(11);
handles.min_clus = clustering_results_bk(1, 5);
handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'});
setUserData({clustering_results_bk(:,2), clustering_results_bk(1,1), clustering_results_bk}, [6, 8, 10])
plot_spikes(handles)

mark_clusters_temperature_diagram(handles)
set(handles.min_clus_edit, 'string', num2str(handles.min_clus));
% updateFixButtonHandle(hObject, handles)
unFixAllClusters();

% --- Executes on button press in merge_button.
function merge_button_Callback(hObject, eventdata, handles)

handles = updateHandles(hObject, handles, {'merge'}, {'setclus', 'reject', 'force', 'undo'});
plot_spikes(handles)
mark_clusters_temperature_diagram(handles)
% updateFixButtonHandle(hObject, handles)
unFixAllClusters();

% --- Executes on button press in Plot_polytrode_channels_button.
function Plot_polytrode_button_Callback(hObject, eventdata, handles)
par = getUserData(1);
if strcmp(par.filename(1:9), 'polytrode')
    Plot_polytrode(handles);
elseif strcmp(par.filename(1:13), 'C_sim_script_')
    handles.simname = par.filename;
    Plot_simulations(handles);
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

handles = updateHandles(hObject, handles, [], {'setclus', 'reject', 'force', 'undo', 'merge'});
plot_spikes(handles);

save_clusters_button_Callback(hObject, eventdata, handles)
load_data_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in excludeTimesButton.
function excludeTimesButton_Callback(hObject, eventdata, handles)
% hObject    handle to excludeTimesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[spike_ts, classes, clustering_results_bk, curr_func] = getUserData([3, 6, 11, 19]);
handles.min_clus = clustering_results_bk(1, 5);
handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'});

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

ts = spike_ts * 1e-3;
if ~isempty(new_func{1})
    f = eval(new_func{1});
    rejectInds = f(ts);
    classes(rejectInds) = 0;
end

setUserData({classes, new_func{1}}, [6, 19]);
plot_spikes(handles)

% --- Executes on button press in mahalDistRemoveSpikes.
function mahalDistRemoveSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to mahalDistRemoveSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('Removing spikes by Mahalanobis Distance...')

[classes, inspk, clustering_results_bk] = getUserData([6, 7, 11]);
handles.min_clus = clustering_results_bk(1, 5);
handles = updateHandles(hObject, handles, {'undo'}, {'setclus', 'reject', 'force', 'merge'});

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
setUserData(classes, 6);
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

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clustersFixedIdx = getFixClusterIndex();
[spikeTime1, spikeTime2] = getFixClusterSpikeTime(clustersFixedIdx);
plot_cross_correlogram(spikeTime1, spikeTime2, clustersFixedIdx(1), clustersFixedIdx(2));


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 1);

% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 2);

% --- Executes when selected object is changed in uibuttongroup3.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 3);


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

unFixAllClusters();


% --- Executes on button press in pushbutton29. plot spike amplitudes
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotSpikeAmplitudes();
