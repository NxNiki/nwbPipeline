function outputFiles = extractLFP(cscFiles, timestampFiles, spikeDetectFiles, spikeClusterFiles, outputPath, experimentName, skipExist, saveRaw)
% remove spikes and downsample csc signal to 2000k hz.
% for macros or micro with no spikes detected remove spikes will be
% skipped.

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
makeOutputPath(cscFiles, outputPath, skipExist);
numFiles = size(cscFiles, 1);
outputFiles = cell(numFiles, 1);

for i = 1: numFiles
    channelFiles = cscFiles(i,:);
    [~, channelFilename] = fileparts(channelFiles{1});
    lfpFilename = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp.mat']);
    lfpFilenameTemp = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp_temp.mat']);
    lfpTimestampFileName = fullfile(outputPath, 'lfpTimestamps.mat');
    
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
    [cscSignal, timestamps, samplingInterval, timestampsStart] = combineCSC(channelFiles, timestampFiles);

    if isempty(cscSignal) || all(isnan(cscSignal))
        return
    else
        outputFiles{i} = lfpFilename;
    end
    disp(samplingInterval)
    Fs = seconds(1) / samplingInterval;

    fprintf('length of csc signal: %d\n', length(cscSignal));

    % check if spike exists for current channel:
    spikeExist = false;
    if ~isempty(spikeDetectFiles) && exist(spikeDetectFiles{i}, "file")
        spikeFileObj = matfile(spikeDetectFiles{i}, 'Writable', false);
        spikes = spikeFileObj.spikes;
        if ~isempty(spikes)
            spikeExist = true;
        end
    end

    if spikeExist
        spikeFileObj = matfile(spikeDetectFiles{i}, 'Writable', false);
        spikes = spikeFileObj.spikes;
        spikeTimestamps = spikeFileObj.spikeTimestamps;

        % the index of last spike should be close to the end of csc signal.
        % except for multi-exp analysis in which case there is large gaps
        % between experiments.
        fprintf('index of last spike: %d\n', spikeTimestamps(end) * Fs);
        if ~removeRejectedSpikes && ~isempty(spikeClusterFiles) && exist(spikeClusterFiles{i}, "file")
            spikeClusterFileObj = matfile(spikeClusterFiles{i});
            rejectedSpikes = spikeClusterFileObj.rejectedSpikes;
            spikes(rejectedSpikes,:) = [];
            spikeTimestamps(rejectedSpikes) = [];
        end
        [cscSignalSpikeInterpolated, spikeIntervalPercentage, interpolateIndex, spikeIndex] = interpolateSpikes(cscSignal, timestamps, spikes, spikeTimestamps);
        spikeGapLength = findGapLength(interpolateIndex);

        % check the distribution of spike gap length:
        figure('Position', [100, 100, 1000, 500], 'Visible', 'off');
        h = histogram(spikeGapLength);
        set(gca, 'YScale', 'log');
        if max(h.Values)*1.1 > min(h.Values(h.Values>0))*.8
            ylim([min(h.Values(h.Values>0))*.8,  max(h.Values)*1.1]);
        end
        [filePath, fileName] = fileparts(channelFiles{1});
        xlabel(sprintf('gap length of interpolation (max gap duration: %.3f seconds)', max(spikeGapLength) * seconds(samplingInterval)), 'FontSize', 15);
        ylabel(['Frequency (', fileName, ')'], 'FontSize', 15);
        title(filePath , 'FontSize', 13);
        saveas(h, fullfile(outputPath, [fileName, '.png']), 'png');
        close
    else
        if ~isempty(spikeDetectFiles) && length(spikeDetectFiles) >= i
            fprintf('spike file: %s not found!\n', spikeDetectFiles{i});
        end
        cscSignalSpikeInterpolated = cscSignal;
        spikeIntervalPercentage = 0;
        interpolateIndex = false(1, length(cscSignal));
        spikeGapLength = [];
        spikeIndex = false(1, length(cscSignal));
    end

    if abs(Fs - 32000) < 10
        Fs = 32000;
    elseif abs(Fs - 30000) < 10
        Fs = 30000;
    elseif abs(Fs - 2000) < 10
        Fs = 2000;
    else
        warning('deviated sampling frequency: %f', Fs);
    end

    [lfpSignal, downsampleTs] = antiAliasing(cscSignalSpikeInterpolated, timestamps, Fs);

    % save LFP:
    lfpFileObj = matfile(lfpFilenameTemp, "Writable", true);
    lfpFileObj.lfp = single(lfpSignal);
    if Fs > 2000
        lfpFileObj.spikeIntervalPercentage = spikeIntervalPercentage;
        lfpFileObj.spikeGapLength = spikeGapLength;
    end
    if saveRaw
        % save Raw data to check interpolation:
        lfpFileObj.cscSignal = cscSignal;
        lfpFileObj.cscSignalSpikeInterpolated = cscSignalSpikeInterpolated;
        lfpFileObj.rawTimestamps = timestamps;
        lfpFileObj.interpolateIndex = interpolateIndex;
        lfpFileObj.spikeIndex = spikeIndex;
        lfpFileObj.numberOfMissingSamples = round(length(cscSignal) * spikeIntervalPercentage);
    end
    movefile(lfpFilenameTemp, lfpFilename);

    % save timestamps:
    if ~exist(lfpTimestampFileName, "file")
        lfpTimestampFileObj = matfile(lfpTimestampFileName, "Writable", true);
        lfpTimestampFileObj.lfpTimestamps = downsampleTs;
        lfpTimestampFileObj.experimentName = experimentName;
        lfpTimestampFileObj.timestampsStart = timestampsStart;
    end
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


