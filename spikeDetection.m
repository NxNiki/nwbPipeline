function spikeDetection(cscFiles, timestampFiles, outputPath, experimentName, skipExist)
%spikeDetection Summary of this function goes here
%   cscFiles cell(m, n). m: number of channels. n: number of files in each
%   channel. spikes detected from file in each row will be combined.


if nargin < 4 || isempty(experimentName)
    experimentName = repmat({''}, length(timestampFiles), 1);
end

if nargin < 5
    skipExist = false;
end


makeOutputPath(cscFiles, outputPath, skipExist)

nSegments = length(timestampFiles);
for j = nSegments:-1:1
    [timestamps{j}, duration(j)] = readTimestamps(timestampFiles{j});
end

for i = 1: size(cscFiles, 1)
    channelFiles = cscFiles(i,:);
    fprintf(['spike detection: \n', sprintf('%s \n', channelFiles{:})])

    spikeFilename = createSpikeFileName(channelFiles{1});
    spikeFilename = fullfile(outputPath, spikeFilename);

    % TO DO: check file completeness:
    if exist(spikeFilename, "file") && skipExist
        continue
    end

    param = set_parameters();
    maxAmp = 500;

    signals = cell(nSegments, 1);
    %outputStruct = cell(nSegments, 1);
    spikes = cell(nSegments, 1);
    spikeCodes = cell(nSegments, 1);
    spikeHist = cell(nSegments, 1);
    spikeHistPrecise = cell(nSegments, 1);
    spikeTimestamps = cell(nSegments, 1);
    thr = zeros(nSegments, 1);

    for j = nSegments:-1:1
        [signals{j}, samplingInterval] = readCSC(channelFiles{j});

        param.sr = 1/samplingInterval;
        param.ref = floor(1.5 * param.sr/1000);
        [thr(j), outputStruct(j)] = getDetectionThresh(signals{j}, param, maxAmp);
    end

    thr_all = min(thr);
    % it shouldn't go less than 18. If it does, it probably found a file with a long stretch of flat, and will then find millions of spikes in the non-flat section.
    thr_all = max(thr_all, 18);
    maxThr = max([outputStruct.thrmax]);
    common_noise_std_detect = min([outputStruct.noise_std_detect]);
    common_noise_std_sorted = min([outputStruct.noise_std_sorted]);

    for j = 1: nSegments
        outputStruct(j).thrmax = maxThr;
        outputStruct(j).noise_std_detect = common_noise_std_detect;
        outputStruct(j).noise_std_sorted = common_noise_std_sorted;
        outputStruct(j).thr = thr_all;

        [spikes{j}, thr, index, outputStruct(j)] = amp_detect_AS(signals{j}, param, maxAmp, timestamps{j}, thr_all, outputStruct(j));
        spikeTimestamps{j} = timestamps{j}(index);
        [spikeCodes{j}, spikeHist{j}, spikeHistPrecise{j}] = getSpikeCodes(spikes{j}, spikeTimestamps{j}, duration(j), param, outputStruct(j));
        if ~isempty(spikeCodes{j})
            spikeCodes{j}.ExpName = repmat(experimentName(j), height(spikeCodes{j}), 1);
        end
    end

    fprintf('write spikes to file:\n %s\n', spikeFilename);
    % remove file if it exist as repetitive writing to save variable in
    % matfile obj consumes increasing memory:
    if exist(spikeFilename, "file")
        delete(spikeFilename);
    end

    matobj = matfile(spikeFilename, 'Writable', true);
    matobj.spikes = vertcat(spikes{:});
    matobj.spikeTimestamps = [spikeTimestamps{:}];
    matobj.thr = thr;
    matobj.param = param;
    matobj.spikeCodes = vertcat(spikeCodes{:});
    matobj.spikeHist = [spikeHist{:}];
    matobj.spikeHistPrecise = [spikeHistPrecise{:}];

end
end



