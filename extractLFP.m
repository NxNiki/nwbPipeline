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
    outputFiles{i} = lfpFilename;

    % TO DO: check file completeness:
    if exist(lfpFilename, "file") && skipExist
        continue
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
    
        cscSignalSpikesRemoved  = removeSpikes(cscSignal, timestamps, spikes, spikeClass, spikeTimestamps, true);
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
        cscSignalSpikesRemoved = cscSignal;
        cscSignalSpikeInterpolated = cscSignal;
        spikeIntervalPercentage = 0;
        interpolateIndex = false(1, length(cscSignal));
        spikeIndex = false(1, length(cscSignal));
    end

    [lfpSignal, downSampledTimestamps, timestampsStart] = antiAliasing(cscSignalSpikesRemoved, timestamps);

    lfpFileObj = matfile(lfpFilename, "Writable", true);
    lfpFileObj.lfp = lfpSignal;
    lfpFileObj.lfpTimestamps = downSampledTimestamps;
    lfpFileObj.experimentName = experimentName;
    lfpFileObj.timestampsStart = timestampsStart;
    lfpFileObj.spikeIntervalPercentage = spikeIntervalPercentage;

    if saveRaw
        lfpFileObj.cscSignal = cscSignal;
        lfpFileObj.cscSignalSpikesRemoved = cscSignalSpikesRemoved;
        lfpFileObj.cscSignalSpikeInterpolated = cscSignalSpikeInterpolated;
        lfpFileObj.rawTimestamps = timestamps;
        lfpFileObj.interpolateIndex = interpolateIndex;
        lfpFileObj.spikeIndex = spikeIndex;
    end

end

