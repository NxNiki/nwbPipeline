function [outputArg1,outputArg2] = spikeDetection(cscFiles, outputPath, skipExist)
%spikeDetection Summary of this function goes here
%   cscFiles cell(m, n). m: number of channels. n: number of files in each
%   channel. 

% 

spikeFilename = ['spikes_', regexp(cscFiles{1}, '.*(?=_\d+\.mat)', 'match', 'once'), '.mat'];
nSegments = length(cscFiles);
param = set_parameters();
maxAmp = 500;

for i = nSegments:-1:1
    [signals{i}, samplingInterval] = readCSC(cscFiles{i});
    
    param.sr = seconds(1)/samplingInterval;
    param.ref = floor(1.5 * param.sr/1000); 
    [thr(i), outputStruct(i)] = getDetectionThresh(signals{i}, param, maxAmp);

    timestamps{i} = readTimestamps(filename);
end

thr_all = min(thr);
% it shouldn't go less than 18. If it does, it probably found a file with a long stretch of flat, and will then find millions of spikes in the non-flat section.
thr_all = max(thr_all, 18); 
maxThr = max([outputStruct.thrmax]);
common_noise_std_detect = min([outputStruct.noise_std_detect]);
common_noise_std_sorted = min([outputStruct.noise_std_sorted]);

for i = 1:nSegments
    fprintf('.');
    outputStruct(i).thrmax = maxThr;
    outputStruct(i).noise_std_detect = common_noise_std_detect;
    outputStruct(i).noise_std_sorted = common_noise_std_sorted;
    outputStruct(i).thr = thr_all;

    [spikes, thr, index, spikeCodes, spikeHist, spikeHistPrecise, ~, ~] = amp_detect_AS(signals{i}, par, maxAmp, timestamps{i}, duration(i), thr_all, outputStruct(i));
    hasSpikesAll{i} = spikeHist;
    hasSpikesPreciseAll{i} = spikeHistPrecise;
    timestamps{i} = timestamps{i}(index); % convert index into msec
end

save_aux(fullfile(outputPath, spikeFilename), spikes, index, thr, spikeCodes, spikeHist, spikeHistPrecise)

end


function [signal, samplingInterval] = readCSC(filename)

matObj = matfile(filename);
signal = matObj.data;
signal = signal(:)';
samplingInterval = seconds(matObj.samplingInterval);

end

function timestamps = readTimestamps(filename)

tsFileObj = matfile(filename);
ts = tsFileObj.timeStamps;
timestamps = ts(:)';

end