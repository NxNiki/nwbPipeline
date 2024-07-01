function [spikes, index, inputStruct, xf_detect] = amp_detect_AS(x, param, inputStruct)
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.

useSinglePrecision = true;

%HIGH-PASS FILTER OF THE DATA
[xf_detect, xf, noise_std_detect, noise_std_sorted, thr, thrmax] = highPassFilter(x, param);

if exist('inputStruct','var') && ~isempty(inputStruct)
    %the data has already been loaded and filtered in a previous step and
    %passed here.
    thrmax = inputStruct.thrmax;
    thr = inputStruct.thr;
else
    inputStruct.noise_std_detect = noise_std_detect;
    inputStruct.noise_std_sorted = noise_std_sorted;
    inputStruct.thr = thr;
    inputStruct.thrmax = thrmax;
end

w_pre = param.w_pre;
w_post = param.w_post;
ref = floor(1.5 * param.sr/1000); % refractory period 
detect = param.detection;
sample_ref = floor(ref/2);
index = [];

% LOCATE SPIKE TIMES
switch detect
    case 'pos'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2-sample_ref) > thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = max((xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((xf(xaux(i)+1:xaux(i)+sample_ref))>thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'neg'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2-sample_ref) < -thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = min((xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((xf(xaux(i)+1:xaux(i)+sample_ref))<thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'both'
        nspk = 0;
        xaux = find(abs(xf_detect(w_pre+2:end-w_post-2-sample_ref)) > thr) +w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [aux_unused, iaux] = max(abs(xf(xaux(i):xaux(i)+sample_ref-1)));    %introduces alignment
                if iaux == 1 && ~any((abs(xf(xaux(i)+1:xaux(i)+sample_ref)))>thr)
                    continue
                end
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
end

% SPIKE STORING (with or without interpolation)
ls = w_pre + w_post;
spikes = zeros(nspk, ls+4);

xf(length(xf)+1:length(xf)+w_post)=0;

for i=1:nspk                          %Eliminates artifacts
    if max(abs( xf(index(i)-w_pre:index(i) + w_post) )) < thrmax
        spikes(i,:)=xf(index(i)-w_pre-1:index(i)+w_post+2);
    end
end
aux = find(spikes(:,w_pre)==0);       %erases indexes that were artifacts
spikes(aux,:)=[];
index(aux)=[];

switch param.interpolation
    case 'n'
        spikes(:,end-1:end)=[];       %eliminates borders that were introduced for interpolation
        spikes(:,1:2)=[];
    case 'y'
        %Does interpolation
        spikes = int_spikes(spikes, param);
end

if isempty(index)
    fprintf('no spikes detected!\n')
    [spikes,index] = deal([]);
end

if useSinglePrecision
    % change data type to single to save memory:
    spikes = single(spikes);
    xf_detect = single(xf_detect);
end



