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
hasSpikes = cell(length(spikeFiles), 1);
hasSpikesPrecise = cell(length(spikeFiles), 1);
outFileNames = cell(length(spikeFiles), 2);

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
        matobj = matfile(outFileNames{fnum, 2}, 'Writable', false);
        hasSpikes{fnum} = matobj.spikeHist;
        hasSpikesPrecise{fnum} = matobj.spikeHistPrecise;
        continue
    elseif exist(outFileNames{fnum, 1}, 'file') && skipExist
        matobj = matfile(outFileNames{fnum, 1}, 'Writable', false);
        hasSpikes{fnum} = matobj.spikeHist;
        hasSpikesPrecise{fnum} = matobj.spikeHistPrecise;
        continue
    else
        % new channels found, will recalculate all across channel
        % spikeCodes.
        updateCrossChannelSpikeCode = true;
    end

    fprintf('get spike codes:\n %s\n', outFileNames{fnum, 1});
    spikeFileObj = matfile(spikeFile, 'Writable', false);
    param = spikeFileObj.param;
    outputStruct = spikeFileObj.outputStruct;
    spikeTimestamps = spikeFileObj.spikeTimestamps;
    duration = spikeFileObj.duration; % expect duration in seconds.
    spikes = spikeFileObj.spikes;

    % get spike codes to run clustering:
    spikeCodes = computeSpikeCodes(spikes, spikeTimestamps, param, outputStruct);
    [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, duration, param.sr);

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

    hasSpikes{fnum} = spikeHist(:);
    hasSpikesPrecise{fnum} = spikeHistPrecise(:);

end

outputFiles = outFileNames(:, 2);
hasSpikes = [hasSpikes{:}];
hasSpikesPrecise = [hasSpikesPrecise{:}];
percentConcurrentSpikes = sum(hasSpikes, 2)/length(spikeFiles);
percentConcurrentSpikesPrecise = sum(hasSpikesPrecise, 2);

% get across channel spike codes:
for fnum = 1:length(spikeFiles)

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

    spikeFileObj = matfile(spikeFiles{fnum}, 'Writable', false);
    duration = spikeFileObj.duration; % expect duration in seconds.
    spikeTimestamps = spikeFileObj.spikeTimestamps;
    param = spikeFileObj.param;

    binEdges = 0:3:1000*(duration)+3;
    binEdgesPrecise = 0:2000/param.sr:1000*duration+1;

    bin = discretize(spikeTimestamps, binEdges);
    fractionConcurrent = percentConcurrentSpikes(bin);
    spikeCodes = [spikeCodes, table(fractionConcurrent(:), 'VariableNames', {'fractionConcurrent'})];

    binPrecise = discretize(spikeTimestamps, binEdgesPrecise);
    fractionConcurrentPrecise = percentConcurrentSpikesPrecise(binPrecise);
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
