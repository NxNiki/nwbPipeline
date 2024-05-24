function outputFiles = spikeDetection(cscFiles, timestampFiles, outputPath, experimentName, skipExist)
%spikeDetection Summary of this function goes here
%   cscFiles cell(m, n). m: number of channels. n: number of files in each
%   channel. spikes detected from file in each row will be combined.


if nargin < 4 || isempty(experimentName)
    experimentName = repmat({''}, length(timestampFiles), 1);
end

if nargin < 5
    skipExist = true;
end

saveXfDetect = false;

makeOutputPath(cscFiles, outputPath, skipExist);
nSegments = length(timestampFiles);
outputFiles = cell(1, size(cscFiles, 1));


parfor i = 1: size(cscFiles, 1)

    channelFiles = cscFiles(i,:);
    spikeFilename = createSpikeFileName(channelFiles{1});
    tempSpikeFilename = ['temp_', spikeFilename];

    spikeFilename = fullfile(outputPath, spikeFilename);
    tempSpikeFilename = fullfile(outputPath, tempSpikeFilename);

    outputFiles{i} = spikeFilename;

    if exist(spikeFilename, "file") && skipExist
        continue
    end

    if exist(tempSpikeFilename, "file")
        delete(tempSpikeFilename);
    end

    fprintf(['spike detection: \n', sprintf('%s \n', channelFiles{:})])

    spikes = cell(nSegments, 1);
    xfDetect = cell(nSegments, 1);
    ExpName = cell(nSegments, 1);
    spikeTimestamps = cell(nSegments, 1);
    duration = 0;

    [thr_all, outputStruct, param, maxAmp] = getDetectionThresh(channelFiles);
    thr = NaN;

    for j = 1: nSegments
        if ~exist(channelFiles{j}, "file")
            fprintf(['missing file in spike detection: \n', sprintf('%s \n', channelFiles{j})]);
            continue
        end

        signal = readCSC(channelFiles{j});
        [timestamps, dur] = readTimestamps(timestampFiles{j});
        duration = duration + dur;

        if j == 1
            timestampsStart = timestamps(1);
        end

        timestamps = timestamps - timestampsStart;
        if saveXfDetect
            [spikes{j}, index, ~, xfDetect{j}] = amp_detect_AS(signal, param, maxAmp, timestamps, thr_all, outputStruct);
        else
            [spikes{j}, index, ~] = amp_detect_AS(signal, param, maxAmp, timestamps, thr_all, outputStruct);
        end

        tsSingle = single(timestamps);
        if length(unique(tsSingle)) == length(timestamps)
            timestamps = tsSingle;
        end

        ExpName{j} = repmat(experimentName(j), size(spikes, 1), 1);
        spikeTimestamps{j} = timestamps(index);

    end

    fprintf('write spikes to file:\n %s\n', spikeFilename);
    % remove file if it exist as repetitive writing to save variable in
    % matfile obj consumes increasing storage:
    if exist(spikeFilename, "file")
        delete(spikeFilename);
    end

    fprintf('write spikes to file:\n %s\n', spikeFilename);
    matobj = matfile(tempSpikeFilename, 'Writable', true);
    matobj.spikes = single(vertcat(spikes{:}));
    matobj.param = param;
    matobj.ExpName = [ExpName{:}];
    matobj.timestampsStart = timestampsStart;
    matobj.outputStruct = outputStruct;
    matobj.spikeTimestamps = [spikeTimestamps{:}];
    matobj.duration = duration;

    if saveXfDetect
        matobj.xfDetect = [xfDetect{:}];
    end

    movefile(tempSpikeFilename, spikeFilename);
end

end



