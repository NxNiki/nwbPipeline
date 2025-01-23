function varargout = wave_clus_aux1(varargin)
% WAVE_CLUS_AUX M-file for wave_clus_aux.fig
%      WAVE_CLUS_AUX, by itself, creates a new WAVE_CLUS_AUX or raises the existing
%      singleton*.
%
%      H = WAVE_CLUS_AUX returns the handle to a new WAVE_CLUS_AUX or the handle to
%      the existing singleton*.
%
%      WAVE_CLUS_AUX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVE_CLUS_AUX.M with the given input arguments.
%
%      WAVE_CLUS_AUX('Property','Value',...) creates a new WAVE_CLUS_AUX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wave_clus_aux_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wave_clus_aux_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wave_clus_aux

% Last Modified by GUIDE v2.5 14-Jan-2025 14:57:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wave_clus_aux_OpeningFcn, ...
                   'gui_OutputFcn',  @wave_clus_aux_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end

% --- Executes just before wave_clus_aux is made visible.
function wave_clus_aux_OpeningFcn(hObject, eventdata, handles)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for wave_clus_aux
handles.output = hObject;

USER_DATA = getUserData();
par = USER_DATA{1};

if par.cluster_index <=8
    handles.clusterIdx = 4:8;
elseif par.cluster_index <=13
    handles.clusterIdx = 9:13;
elseif par.cluster_index <=18
    handles.clusterIdx = 14:18;
elseif par.cluster_index <=23
    handles.clsuterIdx = 19:23;
else
    error('too many clusters!');
end

plotLabelIdx = 4:8;
handles.plotLabelIdx = plotLabelIdx;
radiobuttonIdx = [45, 48, 51, 54, 57];
for i = 1:5
    set(handles.(sprintf('isi%d_accept_button', plotLabelIdx(i))), 'value', 1);
    set(handles.(sprintf('fix%d_button', plotLabelIdx(i))), 'value', 0);
    set(handles.(sprintf('radiobutton%d', radiobuttonIdx(i))), 'value', 1);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wave_clus_aux wait for user response (see UIRESUME)
% uiwait(handles.wave_clus_aux);
end

% --- Outputs from this function are returned to the command line.
function varargout = wave_clus_aux_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;
[par, spikes, spike_times] = getUserData(1:3);
clusterIdx = handles.clusterIdx; % define in plot_spikes.
plotLabelIdx = handles.plotLabelIdx;
for i = 1:5
    set(handles.(sprintf('isi%d_accept_button', plotLabelIdx(i))), 'value', 1);
    set(handles.(sprintf('isi%d_reject_button', plotLabelIdx(i))), 'value', 0);
    set(handles.(sprintf('fix%d_button', plotLabelIdx(i))), 'value', 0);
    set(handles.(sprintf('isi%d_nbins', plotLabelIdx(i))), 'string', par.(sprintf('nbins%d', clusterIdx(i))));
    set(handles.(sprintf('isi%d_bin_step', plotLabelIdx(i))), 'string', par.(sprintf('bin_step%d', clusterIdx(i))));

    % That's for passing the fix button settings to plot_spikes.
    if get(handles.(sprintf('fix%d_button', plotLabelIdx(i))),'value') == 1
        par.(sprintf('fix%d', clusterIdx(i))) = 1;
    else
        par.(sprintf('fix%d', clusterIdx(i))) = 0;
    end
end

setUserData(par, 1);
plot_spikes_aux(handles, par, spikes, spike_times)
end

% Change nbins
% -------------------------------------------------------------
function change_isi_bins(hObject, handles, plotIdx)
    [par, classes] = getUserData([1, 6]);
    clusterIdx = handles.clusterIdx(plotIdx);
    par.(sprintf('nbins%d', clusterIdx)) = str2double(get(hObject, 'String'));
    par.axes_nr = clusterIdx + 1;
    par.class_to_plot = find(classes==clusterIdx);
    setUserData(par, 1);
    plot_spikes_aux(handles)
end

function isi4_nbins_Callback(hObject, eventdata, handles)
    change_isi_bins(hObject, handles, 1);
end

function isi5_nbins_Callback(hObject, eventdata, handles)
    change_isi_bins(hObject, handles, 2);
end

function isi6_nbins_Callback(hObject, eventdata, handles)
    change_isi_bins(hObject, handles, 3);
end

function isi7_nbins_Callback(hObject, eventdata, handles)
    change_isi_bins(hObject, handles, 4);
end

function isi8_nbins_Callback(hObject, eventdata, handles)
    change_isi_bins(hObject, handles, 5);
end
% --------------------------------------------------------------------


% Change bin steps
% -------------------------------------------------------------
function change_isi_bin_step(hObject, handles, plotIdx)
    [par, classes] = getUserData([1, 6]);
    clusterIdx = handles.clusterIdx(plotIdx);
    par.(sprintf('bin_step%d', clusterIdx)) = str2double(get(hObject, 'String'));
    par.axes_nr = clusterIdx+1;
    par.class_to_plot = find(classes==clusterIdx);
    setUserData(par, 1);
    plot_spikes_aux(handles)
end

function isi4_bin_step_Callback(hObject, eventdata, handles)
    change_isi_bin_step(hObject, handles, 1);
end

function isi5_bin_step_Callback(hObject, eventdata, handles)
    change_isi_bin_step(hObject, handles, 2);
end

function isi6_bin_step_Callback(hObject, eventdata, handles)
    change_isi_bin_step(hObject, handles, 3);
end

function isi7_bin_step_Callback(hObject, eventdata, handles)
    change_isi_bin_step(hObject, handles, 4);
end

function isi8_bin_step_Callback(hObject, eventdata, handles)
    change_isi_bin_step(hObject, handles, 5);
end

% Accept and Reject buttons
function reject_buttons(hObject, handles, plotIdx)
    clusterIdx = handles.clusterIdx(plotIdx);
    plotLabelIdx = handles.plotLabelIdx(plotIdx);

    set(hObject, 'value', 1);
    set(handles.(sprintf('isi%d_accept_button', plotLabelIdx)), 'value', 0);
    
    classes = getUserData(6);
    classes(classes==clusterIdx)=0;
    setUserData(classes, [6, 9]);
    
    axes(handles.(sprintf('spikes%d', plotLabelIdx)));
    cla reset
    axes(handles.(sprintf('isi%d', plotLabelIdx)));
    cla reset
    set(hObject,'value',0);
    set(handles.(sprintf('isi%d_accept_button', plotLabelIdx)), 'value', 1);
end

function isi4_accept_button_Callback(hObject, eventdata, handles)
    set(hObject,'value',1);
    set(handles.isi4_reject_button,'value',0);
end

function isi4_reject_button_Callback(hObject, eventdata, handles)
    reject_buttons(hObject, handles, 1)
end

function isi5_accept_button_Callback(hObject, eventdata, handles)
    set(hObject,'value',1);
    set(handles.isi5_reject_button,'value',0);
end

function isi5_reject_button_Callback(hObject, eventdata, handles)
    reject_buttons(hObject, handles, 2)
end

function isi6_accept_button_Callback(hObject, eventdata, handles)
    set(hObject,'value',1);
    set(handles.isi6_reject_button,'value',0);
end

function isi6_reject_button_Callback(hObject, eventdata, handles)
    reject_buttons(hObject, handles, 3)
end

function isi7_accept_button_Callback(hObject, eventdata, handles)
    set(hObject,'value',1);
    set(handles.isi7_reject_button,'value',0);
end

function isi7_reject_button_Callback(hObject, eventdata, handles)
    reject_buttons(hObject, handles, 4)
end

function isi8_accept_button_Callback(hObject, eventdata, handles)
    set(hObject,'value',1);
    set(handles.isi8_reject_button,'value',0);
end

function isi8_reject_button_Callback(hObject, eventdata, handles)
    reject_buttons(hObject, handles, 5)
end

% FIX buttons
function update_fix_button(handles, plotIdx)
    clusterIdx = handles.clusterIdx(plotIdx);
    plotLabelIdx = handles.plotLabelIdx(plotIdx);

    [par, classes] = getUserData([1, 6]);
    fix_class = find(classes==clusterIdx);
    if get(handles.(sprintf('fix%d_button', plotLabelIdx)), 'value') == 1
        par.(sprintf('fix%d', clusterIdx)) = 1;
    else
        fix_class = [];
        par.(sprintf('fix%d', clusterIdx)) = 0;
    end
    
    setUserData({par, fix_class}, [1, 23]);
end

function fix4_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 1);
end

function fix5_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 2);
end

function fix6_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 3);
end

function fix7_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 4);
end

function fix8_button_Callback(hObject, eventdata, handles)
    update_fix_button(handles, 5);
end

% --- Executes during object creation, after setting all properties.
function isi_setbackground(hObject)
    if ispc
        set(hObject,'BackgroundColor', 'white');
    else
        set(hObject,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
    end
end

function isi4_nbins_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi4_bin_step_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi5_nbins_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi5_bin_step_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi6_nbins_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi6_bin_step_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi7_nbins_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi7_bin_step_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi8_nbins_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end
% --- Executes during object creation, after setting all properties.
function isi8_bin_step_CreateFcn(hObject, eventdata, handles)
    isi_setbackground(hObject);
end

% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 4);
end
% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 5);
end
% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 6);
end
% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup4_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 7);
end

% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup5 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateClusterUnit(eventdata, 8);
end

% --- Executes on button press in pushbutton1 (plot_cross_correlogram).
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clustersFixedIdx = getFixClusterIndex();
[spikeTime1, spikeTime2] = getFixClusterSpikeTime(clustersFixedIdx);
plot_cross_correlogram(spikeTime1, spikeTime2, clustersFixedIdx(1), clustersFixedIdx(2));
end