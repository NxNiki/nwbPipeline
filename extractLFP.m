function outputFiles = extractLFP(cscFiles, timestampFiles, spikeFiles, outputPath, experimentName, skipExist, saveRaw)

if nargin < 5 || isempty(experimentName)
    experimentName = '';
end

if nargin < 6 || isempty(skipExist)
    skipExist = true;
end

% save Raw signals to check spikes are removed correctly (see run_plotLFP.m).
if nargin < 7
    saveRaw = false;
end

removeRejectedSpikes = true;

makeOutputPath(cscFiles, outputPath, skipExist)
outputFiles = cell(size(cscFiles, 1), 1);

for i = 1: size(cscFiles, 1)
    channelFiles = cscFiles(i,:);
    fprintf(['extract LFP: \n', sprintf('%s \n', channelFiles{:})])

    [~, channelFilename] = fileparts(channelFiles{1});
    lfpFilename = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp.mat']);
    lfpFilenameTemp = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp_temp.mat']);
    outputFiles{i} = lfpFilename;

    if exist(lfpFilename, "file") && skipExist    
        continue
    end

    if exist(lfpFilenameTemp, "file")
        delete(lfpFilenameTemp);
    end

    % it is better if we can combine the data at 32kHz then filter,
    % to reduce edge effects - especially for the sleep data 
    % (for data that is separated in time there will be edge effects either way)
    % but this will take a lot of memory
    [cscSignal, timestamps, samplingInterval] = combineCSC(channelFiles, timestampFiles);

    fprintf('length of csc signal: %d\n', length(cscSignal));
    if ~isempty(spikeFiles) && exist(spikeFiles{i}, "file")
        spikeFileObj = matfile(spikeFiles{i});
        spikes = spikeFileObj.spikes;
        spikeClass = spikeFileObj.cluster_class(:, 1);
        spikeTimestamps = spikeFileObj.cluster_class(:, 2);

        fprintf('index of last spike: %d\n', (spikeTimestamps(end) - timestamps(1)) * (seconds(1) / samplingInterval));
    
        % cscSignalSpikesRemoved  = removeSpikes(cscSignal, timestamps, spikes, spikeClass, spikeTimestamps, true);
        [cscSignalSpikeInterpolated, spikeIntervalPercentage, interpolateIndex, spikeIndex] = interpolateSpikes(cscSignal, timestamps, spikes, spikeTimestamps);
        
        if removeRejectedSpikes
            rejectedSpikes = spikeFileObj.rejectedSpikes;
            rejectedSpikeTimestamps = rejectedSpikes.index(:);
            [cscSignalSpikeInterpolated, rejectedSpikeIntervalPercentage, interpolateIndexRejected, spikeIndexRejected] = interpolateSpikes(cscSignalSpikeInterpolated, timestamps, rejectedSpikes.spikes, rejectedSpikeTimestamps);
            spikeIntervalPercentage = spikeIntervalPercentage + rejectedSpikeIntervalPercentage;
            interpolateIndex = interpolateIndex | interpolateIndexRejected;
            spikeIndex = spikeIndex | spikeIndexRejected;
        end
    else
        fprintf('spike file: %s not found!\n', spikeFiles{i})
        % cscSignalSpikesRemoved = cscSignal;
        cscSignalSpikeInterpolated = cscSignal;
        spikeIntervalPercentage = 0;
        interpolateIndex = false(1, length(cscSignal));
        spikeIndex = false(1, length(cscSignal));
    end

    [lfpSignal, downSampledTimestamps, timestampsStart] = antiAliasing(cscSignalSpikeInterpolated, timestamps);

    lfpFileObj = matfile(lfpFilenameTemp, "Writable", true);
    lfpFileObj.lfp = lfpSignal;
    lfpFileObj.lfpTimestamps = downSampledTimestamps;
    lfpFileObj.experimentName = experimentName;
    lfpFileObj.timestampsStart = timestampsStart;
    lfpFileObj.spikeIntervalPercentage = spikeIntervalPercentage;
    lfpFileObj.numberOfMissingSamples = round(length(cscSignal) * spikeIntervalPercentage);
    lfpFileObj.spikeGapLength = findGapLength(interpolateIndex);

    if saveRaw
        lfpFileObj.cscSignal = cscSignal;
        % lfpFileObj.cscSignalSpikesRemoved = cscSignalSpikesRemoved;
        lfpFileObj.cscSignalSpikeInterpolated = cscSignalSpikeInterpolated;
        lfpFileObj.rawTimestamps = timestamps;
        lfpFileObj.interpolateIndex = interpolateIndex;
        lfpFileObj.spikeIndex = spikeIndex;
    end

    movefile(lfpFilenameTemp, lfpFilename);

    % ---- check the distribution of spike gap length:
    figure('Position', [100, 100, 1000, 500])
    h = histogram(lfpFileObj.spikeGapLength);
    set(gca, 'YScale', 'log');
    if max(h.Values)*1.1 > min(h.Values(h.Values>0))*.8
        ylim([min(h.Values(h.Values>0))*.8,  max(h.Values)*1.1]);
    end
    [filePath, fileName] = fileparts(channelFiles{1});
    xlabel(sprintf('gap length of interpolation (max gap duration: %.3f seconds)', max(lfpFileObj.spikeGapLength) * seconds(samplingInterval)), 'FontSize', 15);
    ylabel(['Frequency (', fileName, ')'], 'FontSize', 15);
    title(filePath , 'FontSize', 13);
    saveas(h, fullfile(outputPath, [fileName, '.png']), 'png');
    close
    % ---- 

end
end

function gapLength = findGapLength(index)
    % find the length of gaps in the spike index (1: spike interval on raw
    % signal, 0: non-spike intervals.

    index = logical(index);
    
    indexStart = [0, index(1:end-1)];
    diff = index - indexStart;
    
    startIdx = find(diff == 1);
    endIdx = find(diff == -1);
    
    gapLength = endIdx - startIdx;
end


