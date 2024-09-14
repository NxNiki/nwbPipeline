function readData_CSCData(filename, handles)
if isempty(filename)
    [filename, pathname] = uigetfile('*.Ncs','Select file');
end
set(handles.file_name,'string',['Loading:    ' pathname filename]);
cd(pathname);
if length(filename) == 8
    channel = filename(4);
else
    channel = filename(4:5);
end
f=fopen(filename,'r','l');
fseek(f,16384,'bof');                                     %Skip Header, put pointer to the first record
TimeStamps=fread(f,inf,'int64',(4+4+4+2*512));            %Read all TimeStamps
fseek(f,16384+8+4+4+4,'bof');                             %put pointer to the beginning of data
time0 = TimeStamps(1);
timeend = TimeStamps(end);
delta_time=(TimeStamps(2)-TimeStamps(1));
sr = 512*1e6/delta_time;
handles.par = set_parameters_CSC(sr,filename,handles);     % Load parameters
set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));

%Load continuous data
if strcmp(handles.par.tmax,'all')                          %Loads all data
    index_all=[];
    spikes_all=[];
    lts = length(TimeStamps);
    %Segments the data in par.segments pieces
    handles.par.segments = ceil((timeend - time0) / ...
        (handles.par.segments_length * 1e6 * 60));         %number of segments in which data is cutted
    segmentLength = floor (lts/handles.par.segments);
    tsmin = 1 : segmentLength :lts;
    tsmin = tsmin(1:handles.par.segments);
    tsmax = tsmin - 1;
    tsmax = tsmax (2:end);
    tsmax = [tsmax, lts];
    recmax=tsmax;
    recmin=tsmin;
    tsmin = TimeStamps(int64(tsmin));
    tsmax = TimeStamps(int64(tsmax));

    for j=1:length(tsmin)

        Samples=fread(f,512*(recmax(j)-recmin(j)+1),'512*int16=>int16',8+4+4+4);
        x=double(Samples(:))';
        clear Samples;

        %GETS THE GAIN AND CONVERTS THE DATA TO MICRO V.
        eval(['scale_factor=textread(''CSC' num2str(channel) '.Ncs'',''%s'',41);']);
        x=x*str2num(scale_factor{41})*1e6;

        handles.flag = j;                                   %flag for plotting only in the 1st loop
        [spikes,thr,index]  = amp_detect_wc(x,handles);     %detection with amp. thresh.
        index = index*1e6/sr+tsmin(j);
        index_all = [index_all index];
        spikes_all = [spikes_all; spikes];
    end
    index = (index_all-time0)/1000;
    spikes = spikes_all;
    USER_DATA = get(handles.wave_clus_figure,'userdata');
    USER_DATA{2}=spikes;
    USER_DATA{3}=index;
    set(handles.wave_clus_figure,'userdata',USER_DATA);
else                                                        %Loads a data segment
    tsmin = time0 + handles.par.tmin*1e6;                   %min time to read (in micro-sec)
    tsmax = time0 + handles.par.tmax*1e6;                   %max time to read (in micro-sec)
    index_tinitial = find(tsmin > TimeStamps);
    if isempty(index_tinitial) ==1;
        index_tinitial = 0;
    else
        index_tinitial = index_tinitial(end);
    end
    index_tfinal = find(tsmax < TimeStamps);
    if isempty(index_tfinal) ==1;
        index_tfinal = timeend;
    else
        index_tfinal = index_tfinal(1);
    end
    fseek(f,16384+8+4+4+4+index_tinitial,'bof');            %put pointer to the correct time
    Samples=fread(f,512*(index_tfinal-index_tinitial+1),'512*int16=>int16',8+4+4+4);
    x=double(Samples(:))';
    clear Samples;
    [spikes,thr,index] = amp_detect_wc(x,handles);          %Detection with amp. thresh.
end
fclose(f);

[inspk] = wave_features_wc(spikes,handles);                 %Extract spike features.

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
fname_in = handles.par.fname_in;
save([fname_in],'inspk_aux','-ascii');                      %Input file for SPC
handles.par.fnamesave = [handles.par.fname '_ch' ...
    num2str(channel)];                                  %filename if "save clusters" button is pressed
handles.par.fnamespc = handles.par.fname;
handles.par.fname = [handles.par.fname '_wc'];              %Output filename of SPC
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

USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = inspk;
set(handles.wave_clus_figure,'userdata',USER_DATA)
end
