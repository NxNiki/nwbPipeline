function outputFiles = getSpikeCodes(spikeFiles, outputPath, skipExist)
    % SpikeCodes are features used to do clustering analysis. 
    % Most of the spike codes can be calculated for each channel separately.
    % `franctionConcurrent` and `frantionConcurrentPrecise` need information
    % across all channels.

makeOutputPath(spikeFiles, outputPath, skipExist)

hasSpikes = cell(length(spikeFiles), 1);
hasSpikesPrecise = cell(length(spikeFiles), 1);
tempOutFileNames = cell(length(spikeFiles), 1);

% calculate spikeCodes:
for fnum = 1:length(spikeFiles)

    spikeFile = spikeFiles{fnum};
    [~, filename, ext] = fileparts(spikeFile);
    outFile = [strrep(filename, '_spikes', '_spikeCodesTemp'), ext];

    tmpOutFile = ['temp_', outFile];
    tempOutFileNames{fnum} = outFile;

    outFile = fullfile(outputPath, outFile);
    tmpOutFile = fullfile(outputPath, tmpOutFile);

    fprintf('get spike codes:\n %s\n', outFile);
    spikeFileObj = matfile(spikeFile, 'Writable', false);
    param = spikeFileObj.param;
    outputStruct = spikeFileObj.outputStruct;
    spikeTimestamps = spikeFileObj.spikeTimestamps;
    duration = spikeFileObj.duration; % expect duration in seconds.
    spikes = spikeFileObj.spikes;
    
    % get spike codes to run clustering:
    spikeCodes = computeSpikeCodes(spikes, spikeTimestamps, param, outputStruct);
    [spikeHist, spikeHistPrecise] = calculateSpikeHist(spikeTimestamps, duration, par.sr);

    fprintf('write spike codes to file:\n %s\n', outFile);
    if exist(tmpOutFile, "file")
        delete(tmpOutFile);
    end

    matobj = matfile(tmpOutFile, 'Writable', true);
    matobj.spikeHist = spikeHist(:);
    matobj.spikeHistPrecise = spikeHistPrecise(:);
    matobj.spikeCodes = spikeCodes;
    movefile(tmpOutFile, outFile);

    hasSpikes{fnum} = spikeHist(:);
    hasSpikesPrecise{fnum} = spikeHistPrecise(:);
end

outputFiles = cell(length(spikeFiles), 1);
hasSpikes = [hasSpikes{:}];
hasSpikesPrecise = [hasSpikesPrecise{:}];
percentConcurrentSpikes = sum(hasSpikes, 2)/length(spikeFiles);
percentConcurrentSpikesPrecise = sum(hasSpikesPrecise, 2);

% get across channel spike codes:
for fnum = 1:length(tempOutFileNames)
    
    spikeCodeFile = tempOutFileNames{fnum};
    outFile = strrep(spikeCodeFile, '_spikeCodesTemp', '_spikeCodes');

    tempOutFile = fullfile(outputPath, ['temp_', outFile]);
    outFile = fullfile(outputPath, outFile);
    outputFiles{fnum} = outFile;
    
    if exist(outFile, 'file') && skipExist
        delete(fullfile(outputPath, spikeCodeFile));
        continue
    end

    fprintf('get cross channel spike codes:\n %s\n', outFile);
    spikeCodeFileObj = matfile(fullfile(outputPath, spikeCodeFile), 'Writable', false);
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

    if exist(tempOutFile, 'file')
        delete(tempOutFile);
    end

    fprintf('write spike codes to file:\n %s\n', outFile);
    matobj = matfile(tempOutFile, 'Writable', true);
    matobj.spikeCodes = spikeCodes;
    matobj.spikeHist = spikeCodeFileObj.spikeHist;
    matobj.spikeHistPrecise = spikeCodeFileObj.spikeHistPrecise;

    movefile(tempOutFile, outFile);
    delete(fullfile(outputPath, spikeCodeFile));

end

