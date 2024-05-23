function outputFiles = extractLFP(cscFiles, timestampFiles, spikeDetectFiles, spikeClusterFiles, outputPath, experimentName, skipExist, saveRaw)

if nargin < 6 || isempty(experimentName)
    experimentName = '';
end

if nargin < 7 || isempty(skipExist)
    skipExist = true;
end

% save Raw signals to check spikes are removed correctly (see run_plotLFP.m).
if nargin < 8
    saveRaw = false;
end

removeRejectedSpikes = true;

makeOutputPath(cscFiles, outputPath, skipExist)
numFiles = size(cscFiles, 1);
outputFiles = cell(numFiles, 1);

for i = 1: numFiles
    channelFiles = cscFiles(i,:);
    [~, channelFilename] = fileparts(channelFiles{1});
    lfpFilename = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp.mat']);
    lfpFilenameTemp = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp_temp.mat']);
    outputFiles{i} = lfpFilename;

    if exist(lfpFilename, "file") && skipExist    
        continue
    end

    fprintf([sprintf('extract LFP (%d of %d): \n', i, numFiles), sprintf('%s \n', channelFiles{:})])

    if exist(lfpFilenameTemp, "file")
        delete(lfpFilenameTemp);
    end

    % it is better if we can combine the data at 32kHz then filter,
    % to reduce edge effects - especially for the sleep data 
    % (for data that is separated in time there will be edge effects either way)
    % but this will take a lot of memory
    [cscSignal, timestamps, samplingInterval] = combineCSC(channelFiles, timestampFiles);
    timestamps = timestamps - timestamps(1);

    fprintf('length of csc signal: %d\n', length(cscSignal));
    if ~isempty(spikeDetectFiles) && exist(spikeDetectFiles{i}, "file")
        spikeFileObj = matfile(spikeDetectFiles{i});
        spikes = spikeFileObj.spikes;
        spikeCodes = spikeFileObj.spikeCodes;
        spikeTimestamps = spikeCodes.timestamp_sec;

        % the index of last spike should be close to the end of csc signal.
        % except for multi-exp analysis in which case there is large gaps
        % between experiments.
        fprintf('index of last spike: %d\n', spikeTimestamps(end) * (seconds(1) / samplingInterval));

        if ~removeRejectedSpikes && ~isempty(spikeClusterFiles) && exist(spikeClusterFiles{i}, "file")
            spikeClusterFileObj = matfile(spikeClusterFiles{i});
            rejectedSpikes = spikeClusterFileObj.rejectedSpikes;
            spikes(rejectedSpikes,:) = [];
            spikeTimestamps(rejectedSpikes) = [];
        end
        [cscSignalSpikeInterpolated, spikeIntervalPercentage, interpolateIndex, spikeIndex] = interpolateSpikes(cscSignal, timestamps, spikes, spikeTimestamps);
    else
        fprintf('spike file: %s not found!\n', spikeDetectFiles{i})
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
        % save Raw data to check interpolation:
        lfpFileObj.cscSignal = cscSignal;
        lfpFileObj.cscSignalSpikeInterpolated = cscSignalSpikeInterpolated;
        lfpFileObj.rawTimestamps = timestamps;
        lfpFileObj.interpolateIndex = interpolateIndex;
        lfpFileObj.spikeIndex = spikeIndex;
    end

    % ---- check the distribution of spike gap length:
    figure('Position', [100, 100, 1000, 500], 'Visible', 'off');
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

    movefile(lfpFilenameTemp, lfpFilename);

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


