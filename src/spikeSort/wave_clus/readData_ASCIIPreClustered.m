function readData_ASCIIPreClustered(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.mat','Select file');
end
set(handles.file_name,'string',['Loading:    ' pathname filename]);
cd(pathname);

%In case of polytrode data
if strcmp(filename(1:5),'times')
    filename = filename(7:end);
    handles.par = set_parameters_pol(filename,handles);      %Load parameters
else
    handles.par = set_parameters_ascii(filename,handles);      %Load parameters
end

set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));

%Load spikes and parameters
eval(['load times_' filename ';']);
index=cluster_class(:,2)';

%Load clustering results
fname = [handles.par.fname '_' filename(1:end-4)];         %filename for interaction with SPC
clu=load([fname '.dg_01.lab']);
tree=load([fname '.dg_01']);
handles.par.fnamespc = fname;
handles.par.fnamesave = fname;

USER_DATA = get(handles.wave_clus_figure,'userdata');

if exist('ipermut')
    clu_aux = zeros(size(clu,1),length(index)) + 1000;
    for i=1:length(ipermut)
        clu_aux(:,ipermut(i)+2) = clu(:,i+2);
    end
    clu_aux(:,1:2) = clu(:,1:2);
    clu = clu_aux; clear clu_aux
    USER_DATA{12} = ipermut;
end

USER_DATA{2} = spikes;
USER_DATA{3} = index;
USER_DATA{4} = clu;
USER_DATA{5} = tree;
if exist('inspk');
    USER_DATA{7} = inspk;
end
set(handles.wave_clus_figure,'userdata',USER_DATA)

%Load continuous data (for ploting)
if ~strcmp(filename(1:4),'poly')
    load(filename);
    if length(data)> 60*handles.par.sr
        x=data(1:60*handles.par.sr)';
    else
        x=data(1:length(data))';
    end
    [spikes,thr,index] = amp_detect_wc(x, handles);                   %Detection with amp. thresh.
end
end
