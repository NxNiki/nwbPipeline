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

saveXfDetect = false;

makeOutputPath(cscFiles, outputPath, skipExist)
nSegments = length(timestampFiles);

parfor i = 1: size(cscFiles, 1)
    channelFiles = cscFiles(i,:);
    fprintf(['spike detection: \n', sprintf('%s \n', channelFiles{:})])

    spikeFilename = createSpikeFileName(channelFiles{1});
    spikeFilename = fullfile(outputPath, spikeFilename);

    % TO DO: check file completeness:
    if exist(spikeFilename, "file") && skipExist
        continue
    end

    spikes = cell(nSegments, 1);
    spikeCodes = cell(nSegments, 1);
    spikeHist = cell(nSegments, 1);
    spikeHistPrecise = cell(nSegments, 1);
    spikeTimestamps = cell(nSegments, 1);
    xfDetect = cell(nSegments, 1);

    [thr_all, outputStruct, param, maxAmp] = getDetectionThresh(channelFiles);

    for j = 1: nSegments
        if isempty(channelFiles{j}, "file")
            continue
        end

        signal = readCSC(channelFiles{j});
        [timestamps, duration] = readTimestamps(timestampFiles{j});

        if saveXfDetect
            [spikes{j}, thr, index, outputStruct(j), xfDetect{j}] = amp_detect_AS(signal, param, maxAmp, timestamps, thr_all, outputStruct(j));
        else
            [spikes{j}, thr, index, outputStruct(j), ~] = amp_detect_AS(signal, param, maxAmp, timestamps, thr_all, outputStruct(j));
        end

        spikeTimestamps{j} = timestamps(index);
        [spikeCodes{j}, spikeHist{j}, spikeHistPrecise{j}] = getSpikeCodes(spikes{j}, spikeTimestamps{j}, duration, param, outputStruct(j));
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

    if saveXfDetect
        matobj.xfDetect = [xfDetect{:}];
    end

end
end



