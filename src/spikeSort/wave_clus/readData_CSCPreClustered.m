function readData_CSCPreClustered(filename, handles)

if isempty(filename)
    [filename, pathname] = uigetfile('*.Ncs','Select file'); if ~filename,return;end
end
set(handles.file_name,'string',['Loading:    ' pathname filename]);
cd(pathname);
if length(filename) == 8
    channel = filename(4);
else
    channel = filename(4:5);
end
f=fopen(filename,'r','l');
fseek(f,16384,'bof');                                       %Skip Header, put pointer to the first record
TimeStamps=fread(f,inf,'int64',(4+4+4+2*512));              %Read all TimeStamps
time0 = TimeStamps(1);
timeend = TimeStamps(end);
sr = 512*1e6/(TimeStamps(2)-TimeStamps(1));
clear TimeStamps;
handles.par = set_parameters_CSC(sr,filename,handles);      %Load parameters
set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));

%Load spikes and parameters
eval(['load times_CSC' num2str(channel) ';']);
index=cluster_class(:,2)';

%Load clustering results
fname = [handles.par.fname '_ch' num2str(channel)];         %filename for interaction with SPC
clu=load([fname '.dg_01.lab']);
tree=load([fname '.dg_01']);
handles.par.fnamespc = fname;
handles.par.fnamesave = handles.par.fnamespc;

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
if exist('inspk', 'var')
    USER_DATA{7} = inspk;
end
set(handles.wave_clus_figure,'userdata',USER_DATA)

% LOAD CSC DATA (for plotting)
fseek(f,16384+8+4+4+4,'bof');                               %put pointer to the beginning of data
Samples=fread(f,ceil(sr*60),'512*int16=>int16',8+4+4+4);
x=double(Samples(:))';
clear Samples;
fclose(f);

%GETS THE GAIN AND CONVERTS THE DATA TO MICRO V.
eval(['scale_factor=textread(''CSC' num2str(channel) '.Ncs'',''%s'',41);']);
x=x*str2num(scale_factor{41})*1e6;

[spikes,thr,index] = amp_detect_wc(x,handles);              %Detection with amp. thresh.
end