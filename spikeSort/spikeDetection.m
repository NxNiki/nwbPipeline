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

for i = 1: size(cscFiles, 1)

    channelFiles = cscFiles(i,:);

    if all(cellfun(@(x)~exist(x, "file"), cscFiles(i, :)))
        continue
    end

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
    ExpNameId = cell(nSegments, 1);
    spikeTimestamps = cell(nSegments, 1);
    duration = 0;

    [outputStruct, param] = getDetectionThresh(channelFiles);

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
            [spikes{j}, index, ~, xfDetect{j}] = amp_detect_AS(signal, param, outputStruct);
        else
            [spikes{j}, index, ~] = amp_detect_AS(signal, param, outputStruct);
        end

        tsSingle = single(timestamps);
        if length(unique(tsSingle)) == length(timestamps)
            disp('convert timestamps to single precision.')
            timestamps = tsSingle;
        end

        ExpNameId{j} = repmat(j, 1, length(index));
        spikeTimestamps{j} = timestamps(index);
    end

    fprintf('write spikes to file:\n %s\n', tempSpikeFilename);

    % in case server connection is lost:
    try
        matobj = matfile(tempSpikeFilename, 'Writable', true);
        matobj.spikes = single(vertcat(spikes{:}));
        matobj.param = param;
        matobj.ExpNameId = int8([ExpNameId{:}]);
        matobj.ExpName = experimentName;
        matobj.timestampsStart = timestampsStart;
        matobj.outputStruct = outputStruct;
        matobj.spikeTimestamps = [spikeTimestamps{:}];
        matobj.duration = duration;
    
        if saveXfDetect
            matobj.xfDetect = [xfDetect{:}];
        end
        fprintf('save success, rename spike file name to:\n %s\n', spikeFilename);
        movefile(tempSpikeFilename, spikeFilename);
    catch ME
        if exist(tempSpikeFilename, "file")
            delete(tempSpikeFilename);
        end
        if exist(spikeFilename, "file")
            delete(spikeFilename);
        end
        warning('error writing file %s\n:', spikeFilename)
        fprintf('Error message: %s\n', ME.message);
    end
end

outputFiles = outputFiles(cellfun(@(x)~isempty(x), outputFiles));

end



