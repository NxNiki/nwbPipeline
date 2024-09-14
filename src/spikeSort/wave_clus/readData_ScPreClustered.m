function readData_ScPreClustered(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.Nse','Select file');
end
set(handles.file_name, 'string', ['Loading:    ' pathname filename]);
cd(pathname);
if length(filename) == 7
    channel = filename(3);
else
    channel = filename(3:4);
end
eval(['[index, Samples] = Nlx2MatSE(''Sc' num2str(channel) '.Nse'',1,0,0,0,1,0);']);
spikes(:,:)= Samples(:,1,:); clear Samples; spikes = spikes';
handles.par = set_parameters_Sc(filename,handles);          %Load parameters
set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));
axes(handles.cont_data); cla

[spikes] = spike_alignment(spikes,handles);

%Load clustering results
fname = [handles.par.fname '_ch' num2str(channel)];         %filename for interaction with SPC
clu=load([fname '.dg_01.lab']);
tree=load([fname '.dg_01']);
handles.par.fnamespc = fname;
handles.par.fnamesave = handles.par.fnamespc;

USER_DATA = get(handles.wave_clus_figure,'userdata');

if exist('ipermut', 'var')
    clu_aux = zeros(size(clu,1),length(index)) + 1000;
    for i=1:length(ipermut)
        clu_aux(:,ipermut(i)+2) = clu(:,i+2);
    end
    clu_aux(:,1:2) = clu(:,1:2);
    clu = clu_aux; clear clu_aux
    USER_DATA{12} = ipermut;
end

USER_DATA{2} = spikes;
USER_DATA{3} = index/1000;
USER_DATA{4} = clu;
USER_DATA{5} = tree;

set(handles.wave_clus_figure,'userdata',USER_DATA)
end
