function [spikesOut] = int_spikes(spikes, par)
%Interpolates with cubic splines to improve alignment.

w_pre = par.w_pre;
w_post = par.w_post;
ls = w_pre + w_post;
detect = par.detection;
int_factor = par.int_factor;
nspk = size(spikes,1);
extra = (size(spikes,2)-ls)/2;

s = 1:size(spikes,2);
ints = 1/int_factor:1/int_factor:size(spikes,2);
spikesOut = zeros(nspk,ls);
if nspk>0
    intspikes=spline(s, spikes, ints);
    switch detect
        case 'pos'
                [~, iaux] = max(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor),[],2);
        case 'neg'
                [~, iaux] = min(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor),[],2);
        case 'both'
                [~, iaux] = max(abs(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor)),[],2);
    end
    iaux = iaux + (w_pre+extra-1)*int_factor -1;

    for i=1:nspk
        spikesOut(i,:)= intspikes(i,iaux(i)-w_pre*int_factor+int_factor:int_factor:iaux(i)+w_post*int_factor);
    end
end
