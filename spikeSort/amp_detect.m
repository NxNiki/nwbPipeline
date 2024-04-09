% unfinished...

function [spikes,detectionParams,index] = amp_detect(x, param)
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.

sr = param.sr;
w_pre = param.w_pre;
w_post = param.w_post;
ref = param.ref;
detect = param.detection;
stdmin = param.stdmin;
stdmax = param.stdmax;
fmin_detect = param.detect_fmin;
fmax_detect = param.detect_fmax;
fmin_sort = param.sort_fmin;
fmax_sort = param.sort_fmax;

% HIGH-PASS FILTER OF THE DATA
% xf=zeros(length(x),1);        %EM: This gets overwritten, so not sure why
%                                    it's here. Commenting out for now.
if exist('ellip','file')               %Checks for the signal processing toolbox
    [b,a]=ellip(2,0.1,40,[fmin_detect fmax_detect]*2/sr);
    xf_detect=filtfilt(b,a,x);
    [b,a]=ellip(2,0.1,40,[fmin_sort fmax_sort]*2/sr);
    xf=filtfilt(b,a,x);
else
    xf=fix_filter(x);           %Does a bandpass filtering between [300 3000] without the toolbox.
    xf_detect = xf;
end
lx=length(xf);

clear x;

noise_std_detect = median(abs(xf_detect))/0.6745;
noise_std_sorted = median(abs(xf))/0.6745;
thr = stdmin * noise_std_detect;        %thr for detection is based on detected settings.
thrmax = stdmax * noise_std_sorted;     %thrmax for artifact removal is based on sorted settings.

detectionParams.noiseFloor = noise_std_detect;
detectionParams.spikeThresh = thr;
detectionParams.excludeAmp = thrmax;

if isfield(handles,'detectionParams')
    fromThisData = detectionParams;
    detectionParams = handles.detectionParams;
    detectionParams.fromThisData = fromThisData;
    thr = detectionParams.spikeThresh;
    thrmax = max(thrmax,detectionParams.excludeAmp);
end

% LOCATE SPIKE TIMES
switch detect
    case 'pos'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2) > thr) +w_pre+1;
        xaux0 = 0;
        index = zeros(1,length(xaux));
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=max((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'neg'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2) < -thr) +w_pre+1;
        xaux0 = 0;
        index = zeros(1,length(xaux));
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=min((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'both'
        nspk = 0;
        xaux = find(abs(xf_detect(w_pre+2:end-w_post-2)) > thr) +w_pre+1;
        xaux0 = 0;
        index = zeros(1,length(xaux));
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=max(abs(xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
end
index = index(1:nspk);

% SPIKE STORING (with or without interpolation)
ls=w_pre+w_post;
spikes=zeros(nspk,ls+4);
excludedSpikes = spikes;
excludedIndex = index;
xf=[xf zeros(1,w_post)];
for i=1:nspk                          %Eliminates artifacts
    if max(abs( xf(index(i)-w_pre:index(i)+w_post) )) < thrmax               
        spikes(i,:)=xf(index(i)-w_pre-1:index(i)+w_post+2);
    else
        excludedSpikes(i,:) = xf(index(i)-w_pre-1:index(i)+w_post+2);
    end
end
aux = spikes(:,w_pre)==0;       %erases indexes that were artifacts
spikes(aux,:)=[];
index(aux)=[];
excludedSpikes(~aux,:) = [];
excludedIndex(~aux) = [];
detectionParams.excludedSpikes = excludedSpikes;
detectionParams.excludedIndex = excludedIndex;

        
switch param.interpolation
    case 'n'
        spikes(:,end-1:end)=[];       %eliminates borders that were introduced for interpolation 
        spikes(:,1:2)=[];
    case 'y'
        %Does interpolation
        spikes = int_spikes(spikes,handles);   
end


