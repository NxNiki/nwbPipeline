function readData_ScData(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.Nse','Select file');
end
set(handles.file_name,'string',['Loading:    ' pathname filename]);
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

[inspk] = wave_features_wc(spikes,handles);                 %Extract spike features.

if handles.par.permut == 'y'
    if handles.par.match == 'y'
        naux = min(handles.par.max_spk,size(inspk,1));
        ipermut = randperm(length(inspk));
        ipermut(naux+1:end) = [];
        inspk_aux = inspk(ipermut,:);
    else
        ipermut = randperm(length(inspk));
        inspk_aux = inspk(ipermut,:);
    end
else
    if handles.par.match == 'y'
        naux = min(handles.par.max_spk,size(inspk,1));
        inspk_aux = inspk(1:naux,:);
    else
        inspk_aux = inspk;
    end
end

%Interaction with SPC
set(handles.file_name,'string','Running SPC ...');
handles.par.fname_in = 'tmp_data';
fname_in = handles.par.fname_in;
save([fname_in],'inspk_aux','-ascii');                         %Input file for SPC
handles.par.fname = [handles.par.fname '_wc'];             %Output filename of SPC
handles.par.fnamesave = [handles.par.fname '_ch' ...
    num2str(channel)];                                 %filename if "save clusters" button is pressed
handles.par.fnamespc = handles.par.fname;
[clu,tree] = run_cluster(handles);
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
USER_DATA{3} = index/1000;
USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = inspk;
set(handles.wave_clus_figure, 'userdata', USER_DATA)
