function spikeDetection(cscFiles, timestampFiles, outputPath, experimentName, skipExist)
%spikeDetection Summary of this function goes here
%   cscFiles cell(m, n). m: number of channels. n: number of files in each
%   channel.

if nargin < 4 || isempty(experimentName)
    experimentName = repmat({''}, length(timestampFiles), 1);
end

if nargin < 5
    skipExist = false;
end


if ~exist(outputPath, "dir")
    mkdir(outputPath);
elseif ~skipExist
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed in t1, t2 stops with 5 files processed, we cannot start
    % with the 6th file in t3 as we have 10 files saved.
    rmdir(outputPath, 's');
    mkdir(outputPath);
end

nSegments = length(timestampFiles);
for j = nSegments:-1:1
    [timestamps{j}, dur] = readTimestamps(timestampFiles{j});
    duration(j) = seconds(dur);
end

for i = 1: size(cscFiles, 1)
    channelFiles = cscFiles(i,:);
    spikeFilename = fullfile(outputPath, ['spikes_', regexp(channelFiles{1}, '.*(?=_\d+\.mat)', 'match', 'once'), '.mat']);

    % TO DO: check file completeness:
    if exist(spikeFilename, "file") && skipExist
        continue
    end

    param = set_parameters();
    maxAmp = 500;

    for j = nSegments:-1:1
        [signals{j}, samplingInterval] = readCSC(channelFiles{j});

        param.sr = seconds(1)/samplingInterval;
        param.ref = floor(1.5 * param.sr/1000);
        [thr(j), outputStruct(j)] = getDetectionThresh(signals{j}, param, maxAmp);
    end

    thr_all = min(thr);
    % it shouldn't go less than 18. If it does, it probably found a file with a long stretch of flat, and will then find millions of spikes in the non-flat section.
    thr_all = max(thr_all, 18);
    maxThr = max([outputStruct.thrmax]);
    common_noise_std_detect = min([outputStruct.noise_std_detect]);
    common_noise_std_sorted = min([outputStruct.noise_std_sorted]);

    for j = nSegments:-1:1
        fprintf('.');
        outputStruct(j).thrmax = maxThr;
        outputStruct(j).noise_std_detect = common_noise_std_detect;
        outputStruct(j).noise_std_sorted = common_noise_std_sorted;
        outputStruct(j).thr = thr_all;

        [spikes{j}, thr, index, spikeCodes{j}, spikeHist{j}, spikeHistPrecise{j}, ~, ~] = amp_detect_AS(signals{j}, param, maxAmp, timestamps{j}, duration(j), thr_all, outputStruct(j));
        spikeTimestamps{j} = timestamps{j}(index);
        spikeCodes{j}.ExpName = experimentName{j};
    end

    matobj = matfile(spikeFilename, 'Writable', true);
    matobj.spikes = [spikes{:}];
    matobj.spikeTimestamps = [spikeTimestamps{:}];
    matobj.thr = thr;
    matobj.spikeCodes = vertcat(spikeCodes{:});
    matobj.spikeHist = [spikeHist{:}];
    matobj.spikeHistPrecise = [spikeHistPrecise{:}];

end
end


function [signal, samplingInterval] = readCSC(filename)

matObj = matfile(filename);
signal = matObj.data;
signal = signal(:)';
samplingInterval = seconds(matObj.samplingInterval);

end

function [timestamps, duration] = readTimestamps(filename)

tsFileObj = matfile(filename);
ts = tsFileObj.timeStamps;
timestamps = ts(:)';
duration = tsFileObj.timeend - tsFileObj.time0;

end