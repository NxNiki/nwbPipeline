function outputFiles = getSpikeCodes(spikeFiles, outputPath, skipExist)
% SpikeCodes are features used to do clustering analysis.
% Most of the spike codes can be calculated for each channel separately.
% `franctionConcurrent` and `frantionConcurrentPrecise` need information
% across all channels.
% Note: will not skipExist if more channels are added as this will change
% across channel spikeCodes (fractionConcurrent and
% fractionConcurrentPrecise).

updateCrossChannelSpikeCode = false;

makeOutputPath(spikeFiles, outputPath, skipExist)
hasSpikesSum = [];
hasSpikesPreciseSum = [];
outFileNames = cell(length(spikeFiles), 2);
binEdges = [];

% calculate spikeCodes:
for fnum = 1:length(spikeFiles)

    if ~exist(spikeFiles{fnum}, 'file')
        continue
    end

    spikeFile = spikeFiles{fnum};
    [~, filename, ext] = fileparts(spikeFile);

    % spike codes without cross channel features:
    outFileNames{fnum, 1} = fullfile(outputPath, [strrep(filename, '_spikes', '_spikeCodes1'), ext]);
    % spike codes with cross channel features:
    outFileNames{fnum, 2} = fullfile(outputPath, [strrep(filename, '_spikes', '_spikeCodes'), ext]);

    if exist(outFileNames{fnum, 2}, 'file') && skipExist
        fprintf('read existing spike codes:\n %s\n', outFileNames{fnum, 2});
        matobj = matfile(outFileNames{fnum, 2}, 'Writable', false);
        hasSpikes = matobj.spikeHist;
        hasSpikesPrecise = matobj.spikeHistPrecise;
    elseif exist(outFileNames{fnum, 1}, 'file') && skipExist
        fprintf('read existing spike codes:\n %s\n', outFileNames{fnum, 1});
        matobj = matfile(outFileNames{fnum, 1}, 'Writable', false);
        hasSpikes = matobj.spikeHist;
        hasSpikesPrecise = matobj.spikeHistPrecise;
    else
        % new channels found, will recalculate all across channel
        % spikeCodes.
        updateCrossChannelSpikeCode = true;
        spikeFileObj = matfile(spikeFile, 'Writable', false);
        param = spikeFileObj.param;
        outputStruct = spikeFileObj.outputStruct;

        if ~ismember('spikeTimestamps', who(spikeFileObj))
            continue;
        end
        fprintf('compute spike codes:\n %s\n', outFileNames{fnum, 1});
        spikeTimestamps = spikeFileObj.spikeTimestamps;
        duration = spikeFileObj.duration; % expect duration in seconds.
        spikes = spikeFileObj.spikes;

        % get spike codes to run clustering:
        spikeCodes = computeSpikeCodes(spikes, spikeTimestamps, param, outputStruct);

        fprintf('duration: %s seconds, sampling rate: %d Hz\n', num2str(duration), param.sr);
        if isempty(binEdges)
            % assume duration and sr is same across files:
            [binEdges, binEdgesPrecise] = createBinEdge(duration, param.sr);
        end
        [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, binEdges, binEdgesPrecise);

        tmpOutFile = strrep(outFileNames{fnum, 1}, '_spikeCodes1', '_spikeCodes1Temp');
        fprintf('write spike codes to file:\n %s\n', tmpOutFile);
        if exist(tmpOutFile, "file")
            % delete unfinished temp file created in previous jobs. Otherwise
            % writing to existing mat file will increase file size.
            delete(tmpOutFile);
        end

        matobj = matfile(tmpOutFile, 'Writable', true);
        matobj.spikeHist = spikeHist(:);
        matobj.spikeHistPrecise = spikeHistPrecise(:);
        matobj.spikeCodes = spikeCodes;
        movefile(tmpOutFile, outFileNames{fnum, 1});

        hasSpikes = spikeHist(:);
        hasSpikesPrecise = spikeHistPrecise(:);
    end

    disp('update hasSpikesSum...');
    hasSpikesSum = updateHasSpikesSum(hasSpikesSum, hasSpikes);
    hasSpikesPreciseSum = updateHasSpikesSum(hasSpikesPreciseSum, hasSpikesPrecise);
end

hasSpikes = [];
hasSpikesPrecise = [];
spikeHist = [];
spikeHistPrecise = [];
spikeCodes = [];
spikeTimestamps = [];

outputFiles = outFileNames(:, 2);
percentConcurrentSpikes = hasSpikesSum/length(spikeFiles);
percentConcurrentSpikesPrecise = hasSpikesPreciseSum;

hasSpikesSum = [];
hasSpikesPreciseSum = [];

% get across channel spike codes:
parfor fnum = 1:length(spikeFiles)

    if exist(outFileNames{fnum, 2}, 'file') && skipExist && ~updateCrossChannelSpikeCode
        continue
    end

    fprintf('get cross channel spike codes:\n %s\n', outFileNames{fnum, 2});

    if exist(outFileNames{fnum, 1}, 'file')
        spikeCodeFileObj = matfile(outFileNames{fnum, 1}, 'Writable', false);
    else
        spikeCodeFileObj = matfile(outFileNames{fnum, 2}, 'Writable', false);
    end

    spikeCodes = spikeCodeFileObj.spikeCodes;

    if isempty(spikeCodes)
        continue;
    end

    spikeFileObj = matfile(spikeFiles{fnum}, 'Writable', false);
    duration = spikeFileObj.duration; % expect duration in seconds.
    spikeTimestamps = spikeFileObj.spikeTimestamps;
    param = spikeFileObj.param;

    [binEdges, binEdgesPrecise] = createBinEdge(duration, param.sr);
    bin = discretize(spikeTimestamps, binEdges);
    fractionConcurrent = percentConcurrentSpikes(bin);
    if ismember('fractionConcurrent', spikeCodes.Properties.VariableNames)
        spikeCodes = removevars(spikeCodes, {'fractionConcurrent'});
    end
    spikeCodes = [spikeCodes, table(fractionConcurrent(:), 'VariableNames', {'fractionConcurrent'})];

    binPrecise = discretize(spikeTimestamps, binEdgesPrecise);
    fractionConcurrentPrecise = percentConcurrentSpikesPrecise(binPrecise);
    if ismember('fractionConcurrentPrecise', spikeCodes.Properties.VariableNames)
        spikeCodes = removevars(spikeCodes, {'fractionConcurrentPrecise'});
    end
    spikeCodes = [spikeCodes, table(fractionConcurrentPrecise(:), 'VariableNames', {'fractionConcurrentPrecise'})];

    tempOutFile = strrep(outFileNames{fnum, 2}, '_spikeCodes', '_spikeCodesTemp');
    if exist(tempOutFile, 'file')
        delete(tempOutFile);
    end

    fprintf('write spike codes to file:\n %s\n', tempOutFile);
    matobj = matfile(tempOutFile, 'Writable', true);
    matobj.spikeCodes = spikeCodes;
    matobj.spikeHist = spikeCodeFileObj.spikeHist;
    matobj.spikeHistPrecise = spikeCodeFileObj.spikeHistPrecise;

    movefile(tempOutFile, outFileNames{fnum, 2});
    delete(outFileNames{fnum, 1});

end
end

function hasSpikeSum = updateHasSpikesSum(hasSpikeSum, hasSpikes)
% As this function updates hasSpikeSum, make sure the output variable has
% the same name as the first input arg when calling this function!

    if isempty(hasSpikeSum)
        hasSpikeSum = hasSpikes(:);
    else
        hasSpikeSum = sum([hasSpikeSum(:), hasSpikes(:)], 2);
    end

end
