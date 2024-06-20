function [ latencies, indices ] = getSpikeLatencies( stim_onsets, spike_times, epoch)
%GETSPIKELATENCIES gets latencies of all spikes belonging to trial epochs
%   Detailed explanation goes here

    spike_times = sort(spike_times);

    lb = arrayfun(@(x) closest_value(spike_times, x, 0), stim_onsets + epoch(1));
    ub = arrayfun(@(x) closest_value(spike_times, x, 1), stim_onsets + epoch(2));
    indices = arrayfun(@(lb,ub) lb+1:ub-1, lb, ub, 'UniformOutput',0);
    latencies = arrayfun(@(lb,ub,stimOnsetTimes) spike_times(lb+1:ub-1)-stimOnsetTimes, lb, ub, stim_onsets, 'UniformOutput',0);

end

function [inf] = closest_value(arr, val, greater)
% Returns value and index of increasing arr that is closest to val using
% binary search. If several entries are equally close, return the first.
% Works fine up to machine error (e.g. [v, i] = closest_value([4.8, 5],
% 4.9) will return [5, 2], since in float representation 4.9 is strictly
% closer to 5 than 4.8).
% ===============
% Parameter list:
% ===============
% arr : increasingly ordered array
% val : scalar in R
len = length(arr); inf = 1; sup = len;
if nargin < 3
    greater = 0;
end
% Binary search for index
while sup - inf > 1
    med = floor((sup + inf)/2);    
    % Replace >= here with > to obtain the last index instead of the first.
    if arr(med) > val 
        sup = med;
    elseif arr(med) == val
        sup = med; inf = med;
    else
        inf = med;
    end
end
if greater, inf = sup; end
end
