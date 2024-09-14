function readData_ASCII(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.mat','Select file');
end
set(handles.file_name, 'string', ['Loading:    ' pathname filename]);
cd(pathname);
handles.par = set_parameters_ascii(filename,handles);       %Load parameters
set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));

index_all=[];
spikes_all=[];
for j=1:handles.par.segments                                %that's for cutting the data into pieces
    % LOAD CONTINUOUS DATA
    load(filename);
    x=data(:)';
    tsmin = (j-1)*floor(length(data)/handles.par.segments)+1;
    tsmax = j*floor(length(data)/handles.par.segments);
    x=data(tsmin:tsmax); clear data;
    handles.flag = 1;                                      %flag for ploting only in the 1st loop

    % SPIKE DETECTION WITH AMPLITUDE THRESHOLDING
    [spikes,thr,index]  = amp_detect_wc(x,handles);        %detection with amp. thresh.
    index=index+tsmin-1;

    index_all = [index_all index];
    spikes_all = [spikes_all; spikes];
end
index = index_all *1e3/handles.par.sr;                     %spike times in ms.
spikes = spikes_all;

USER_DATA = get(handles.wave_clus_figure,'userdata');
USER_DATA{2}=spikes;
USER_DATA{3}=index;
set(handles.wave_clus_figure,'userdata',USER_DATA);

[inspk] = wave_features_wc(spikes,handles);                %Extract spike features.

if handles.par.permut == 'y'
    if handles.par.match == 'y';
        naux = min(handles.par.max_spk,size(inspk,1));
        ipermut = randperm(length(inspk));
        ipermut(naux+1:end) = [];
        inspk_aux = inspk(ipermut,:);
    else
        ipermut = randperm(length(inspk));
        inspk_aux = inspk(ipermut,:);
    end
else
    if handles.par.match == 'y';
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
save([fname_in], 'inspk_aux', '-ascii');                         %Input file for SPC
handles.par.fnamesave = [handles.par.fname '_' ...
    filename(1:end-4)];                                          %filename if "save clusters" button is pressed
handles.par.fname = [handles.par.fname '_wc'];                   %Output filename of SPC
handles.par.fnamespc = handles.par.fname;

[clu,tree] = run_cluster(handles);
USER_DATA = get(handles.wave_clus_figure, 'userdata');

if exist('ipermut', 'var')
    clu_aux = zeros(size(clu,1),length(index)) + 1000;
    for i=1:length(ipermut)
        clu_aux(:,ipermut(i)+2) = clu(:,i+2);
    end
    clu_aux(:,1:2) = clu(:,1:2);
    clu = clu_aux; clear clu_aux
    USER_DATA{12} = ipermut;
end

USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = inspk;
set(handles.wave_clus_figure,'userdata', USER_DATA)
end
